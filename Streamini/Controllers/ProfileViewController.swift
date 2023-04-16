//
//  ProfileViewController.swift
// Streamini
//
//  Created by Vasily Evreinov on 11/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit
import MessageUI
import TwitterKit

enum ProfileActionSheetType: Int {
    case changeAvatar
    case logout
}

protocol ProfileDelegate: class {
    func reload()
    func close()
}

class ProfileViewController: BaseTableViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, AmazonToolDelegate, UserHeaderViewDelegate, MFMailComposeViewControllerDelegate,
ProfileDelegate {
    @IBOutlet weak var userHeaderView: UserHeaderView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followingValueLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followersValueLabel: UILabel!
    @IBOutlet weak var blockedLabel: UILabel!
    @IBOutlet weak var blockedValueLabel: UILabel!
    @IBOutlet weak var streamsLabel: UILabel!
    @IBOutlet weak var streamsValueLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var earningsLabel: UILabel!
    @IBOutlet weak var earningsValueLabel: UILabel!
    
    @IBOutlet weak var friendsLabel: UILabel!
    
    var user: User?
    var profileDelegate: ProfileDelegate?
    var selectedImage: UIImage?
    
    @IBAction func avatarButtonPressed(_ sender: AnyObject) {
        let actionSheet = UIActionSheet.changeUserpicActionSheet(self)
        actionSheet.tag = ProfileActionSheetType.changeAvatar.rawValue
        actionSheet.show(in: self.view)
    }
    
    func logout() {
        let actionSheet = UIActionSheet.confirmLogoutActionSheet(self)
        actionSheet.tag = ProfileActionSheetType.logout.rawValue
        actionSheet.show(in: self.view)
    }
    
    func configureView() {
        self.title = NSLocalizedString("profile_title", comment: "")
        followingLabel.text = NSLocalizedString("profile_following", comment: "")
        followersLabel.text = NSLocalizedString("profile_followers", comment: "")
        blockedLabel.text   = NSLocalizedString("profile_blocked", comment: "")
        streamsLabel.text   = NSLocalizedString("profile_streams", comment: "")
        shareLabel.text     = NSLocalizedString("profile_share", comment: "")
        feedbackLabel.text  = NSLocalizedString("profile_feedback", comment: "")
        termsLabel.text     = NSLocalizedString("profile_terms", comment: "")
        privacyLabel.text   = NSLocalizedString("profile_privacy", comment: "")
        logoutLabel.text    = NSLocalizedString("profile_logout", comment: "")
        earningsLabel.text  = NSLocalizedString("your_earnings", comment: "")
        friendsLabel.text  = NSLocalizedString("friends", comment: "")
        
        userHeaderView.delegate = self
    }
    
    func successGetUser(_ user: User) {
        self.user = user
        userHeaderView.update(user)
        
        followingValueLabel.text    = "\(user.following)"
        followersValueLabel.text    = "\(user.followers)"
        blockedValueLabel.text      = "\(user.blocked)"
        streamsValueLabel.text      = "\(user.streams)"
        earningsValueLabel.text     = "\(user.earned)"
        
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func successFailure(_ error: NSError) {
        handleError(error)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.tag == ProfileActionSheetType.changeAvatar.rawValue {
            if (buttonIndex == 1) { // Gallery
                let controller = UIImagePickerController()
                controller.sourceType = UIImagePickerController.SourceType.photoLibrary
                controller.allowsEditing = true
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            }
            
            if (buttonIndex == 2) { // Camera
                let controller = UIImagePickerController()
                controller.sourceType = UIImagePickerController.SourceType.camera
                controller.allowsEditing = true
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }
        
        if actionSheet.tag == ProfileActionSheetType.logout.rawValue {
            if buttonIndex != actionSheet.cancelButtonIndex {
                UserConnector().logout(logoutSuccess, failure: logoutFailure)
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        picker.dismiss(animated: true, completion: { () -> Void in
            self.selectedImage = image.fixOrientation().imageScaledToFitToSize(CGSize(width: 100, height: 100))
            self.uploadImage(self.selectedImage!)
        })
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        navigationController.navigationBar.tintColor = UIColor.black
//        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Ultra", size: 18)!, NSAttributedString.Key.foregroundColor : UIColor.black]

    }
    
    func uploadImage(_ image: UIImage) {
        let filename = "\(UserContainer.shared.logged().id)-avatar.jpg"
                        
        if AmazonTool.isAmazonSupported() {
            AmazonTool.shared.uploadImage(image, name: filename) { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                DispatchQueue.main.sync(execute: { () -> Void in
                    let progress: Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                    self.userHeaderView.progressView.setProgress(progress, animated: true)
                })
            }
        } else {
            let data = image.jpegData(compressionQuality: 1.0)!
            UserConnector().uploadAvatar(filename, data: data, success: uploadAvatarSuccess, failure: uploadAvatarFailure, progress: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                    let progress: Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                    self.userHeaderView.progressView.setProgress(progress, animated: true)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        let activator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        activator.startAnimating()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activator)
        UserConnector().get(nil, success: successGetUser, failure: successFailure)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AmazonTool.shared.delegate = self
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        UINavigationBar.setCustomAppereance()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AmazonTool.shared.delegate = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sid = segue.identifier {
            if sid == "ProfileToLegal" {
                let controller = segue.destination as! LegalViewController
                let index = (sender as! IndexPath).row
                controller.type = (index == 2) ? LegalViewControllerType.termsOfService : LegalViewControllerType.privacyPolicy
            }
            
            if sid == "ProfileToPaypal" {
                let controller = segue.destination as! PaypalViewController
                controller.profileController = self
            }
            
            if sid == "ProfileToProfileStatistics" {
                let controller = segue.destination as! ProfileStatisticsViewController
                let index = (sender as! IndexPath).row
                controller.type = ProfileStatisticsType(rawValue: index)!
                controller.profileDelegate = self
            }
            if sid == "ProfileToEpisodes" {
                let controller = segue.destination as! EpisodesVC
                controller.profileDelegate = self
                isPlaylist = false
            }
        }
    }
    
    // MARK: - AmazonToolDelegate
    
    func uploadAvatarSuccess() {
        userHeaderView.progressView.setProgress(0.0, animated: false)
        userHeaderView.updateAvatar(user!, placeholder: selectedImage!)
        if let delegate = profileDelegate {
            delegate.reload()
        }
    }
    
    func uploadAvatarFailure(_ error: NSError) {
        handleError(error)
    }
    
    func imageDidUpload() {
        UserConnector().avatar(uploadAvatarSuccess, failure: uploadAvatarFailure)
    }
    
    func imageUploadFailed(_ error: NSError) {
        handleError(error)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logoutSuccess() {
        if let session = A0SimpleKeychain().string(forKey: "PHPSESSID") {
            A0SimpleKeychain().deleteEntry(forKey: "PHPSESSID")
        }
        if let id = A0SimpleKeychain().string(forKey: "id") {
            A0SimpleKeychain().deleteEntry(forKey: "id")
        }
        if let token = A0SimpleKeychain().string(forKey: "token") {
            A0SimpleKeychain().deleteEntry(forKey: "token")
        }
        if let secret = A0SimpleKeychain().string(forKey: "secret") {
            A0SimpleKeychain().deleteEntry(forKey: "secret")
        }
        if let type = A0SimpleKeychain().string(forKey: "type") {
            A0SimpleKeychain().deleteEntry(forKey: "type")
        }
        
        // deprecated Twitter.sharedInstance().logOut()
        
        let store = TWTRTwitter.sharedInstance().sessionStore
        
        if let userID = store.session()?.userID {
            store.logOutUserID(userID)
        }
        
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    func logoutFailure(_ error: NSError) {
        print("failure", terminator: "")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 1 && indexPath.row == 0 { // Paypal
            self.performSegue(withIdentifier: "ProfileToPaypal", sender: indexPath)
        }
        else if indexPath.section == 1 && indexPath.row == 4 {
            self.performSegue(withIdentifier: "ProfileToEpisodes", sender: indexPath)
        }
        else if indexPath.section == 1 { // following, followers, blocked, streams
            self.performSegue(withIdentifier: "ProfileToProfileStatistics", sender: indexPath)
        }
        
        if indexPath.section == 2 && indexPath.row == 0 { // share
            UINavigationBar.resetCustomAppereance()
            let shareMessage = NSLocalizedString("profile_share_message", comment: "")
            let activityController = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
        }
        
        if indexPath.section == 2 && indexPath.row == 1 { // feedback
            UINavigationBar.resetCustomAppereance()
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                let alert = UIAlertView.mailUnavailableErrorAlert()
                alert.show()
            }
        }
        
        if indexPath.section == 2 && indexPath.row == 2 { // Terms Of Service
            self.performSegue(withIdentifier: "ProfileToLegal", sender: indexPath)
        }
        
        if indexPath.section == 2 && indexPath.row == 3 { // Privacy Policy
            self.performSegue(withIdentifier: "ProfileToLegal", sender: indexPath)
        }
        
        if indexPath.section == 3 { // logout
            logout()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([Config.shared.feedback()])
        mailComposerVC.setSubject(NSLocalizedString("feedback_title", comment: ""))
        
        let appVersion  = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let appBuild    = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let deviceName  = UIDevice.current.name
        let iosVersion  = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        let userId      = user!.id
        
        var message = "\n\n\n"
        message = message + "App Version: \(appVersion)\n"
        message = message + "App Build: \(appBuild)\n"
        message = message + "Device Name: \(deviceName)\n"
        message = message + "iOS Version: \(iosVersion)\n"
        message = message + "User Id: \(userId)"
        
        mailComposerVC.setMessageBody(message, isHTML: false)
        
        mailComposerVC.delegate = self
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //controller.dismissViewControllerAnimated(true, completion: nil)
        controller.dismiss(animated: true, completion: { () -> Void in
            if result.rawValue == MFMailComposeResult.failed.rawValue {
                let alert = UIAlertView.sendMailErrorAlert()
                alert.show()
            }
        })
    }
    
    // MARK: - ProfileDelegate
    
    func reload() {
        UserConnector().get(nil, success: successGetUser, failure: successFailure)
    }
    
    func close() {
    }
    
    // MARK: - UserHeaderViewDelegate
    
    func closeButtonPressed(_ sender: AnyObject) {
    }
    
    func usernameLabelPressed() {        
    }
    
    func descriptionWillStartEdit() {
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(ProfileViewController.doneButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = doneBarButtonItem
    }
    
    @objc func doneButtonPressed(_ sender: AnyObject) {
        let text: String
        if userHeaderView.userDescriptionTextView.text == NSLocalizedString("profile_description_placeholder", comment: "") {
            text = " "
        } else {
            text = userHeaderView.userDescriptionTextView.text
        }
        
        let activator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        activator.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activator)
        
        UserConnector().userDescription(text, success: userDescriptionTextSuccess, failure: userDescriptionTextFailure)
    }
    
    func userDescriptionTextSuccess() {
        self.navigationItem.rightBarButtonItem = nil
        userHeaderView.userDescriptionTextView.resignFirstResponder()
        
        if let delegate = profileDelegate {
            delegate.reload()
        }
    }
    
    func userDescriptionTextFailure(_ error: NSError) {
        handleError(error)
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(ProfileViewController.doneButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = doneBarButtonItem
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
