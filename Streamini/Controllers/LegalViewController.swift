//
//  LegalViewController.swift
// Streamini
//
//  Created by Vasily Evreinov on 17/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

enum LegalViewControllerType {
    case termsOfService
    case privacyPolicy
}

class LegalViewController: BaseViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    var type: LegalViewControllerType?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString: String
        switch type! {
        case .termsOfService:
            urlString = Config.shared.legal().termsOfService
            self.title = NSLocalizedString("profile_terms", comment: "")
        case .privacyPolicy:
            urlString = Config.shared.legal().privacyPolicy
            self.title = NSLocalizedString("profile_privacy", comment: "")
        }
        
        let url = URL(string: urlString)!
        webView.loadRequest(URLRequest(url: url))
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if navigationType == UIWebView.NavigationType.linkClicked {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        return true
    }
    
    // MARK: - Memory management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
