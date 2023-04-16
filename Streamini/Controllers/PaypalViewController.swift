//
//  PaypalViewController.swift
//  Streamini
//
//  Created by Vasiliy Evreinov on 18.07.16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

import UIKit

class PaypalViewController: BaseViewController {

    @IBOutlet weak var paypalField: UITextField!
    @IBOutlet weak var earningsLabel: UILabel!
    
    var profileController: ProfileViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pp:String = profileController!.user!.paypal
        if(pp != "")
        {
            paypalField.text = pp
        }
        
        paypalField.placeholder = NSLocalizedString("input_paypal", comment: "")
        earningsLabel.text = String(format:"%@: %d", NSLocalizedString("your_earnings", comment: ""), profileController!.user!.earned)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let text = paypalField.text
        UserConnector().userPaypal(text!, success: userSuccess, failure: userFailure)
        
    }
    
    func userSuccess() {
        // do nothing
        profileController!.user!.paypal = paypalField.text!
    }
    
    func userFailure(_ error: NSError) {
        handleError(error)
    }
    
}
