//
//  UIAlertViewExtensions.swift
//  Streamini
//
//  Created by Vasily Evreinov on 24/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

extension UIAlertView {
    
    class func reportConfirmationAlert(_ streamTitle: String, delegate: UIAlertViewDelegate) -> UIAlertView {
        let alertTitle      = NSLocalizedString("report_stream_alert_title", comment: "")
        
        let format          = NSLocalizedString("report_stream_alert_message", comment: "")
        let alertMessage    = NSString(format: format as NSString, streamTitle) as String
        
        let yes             = NSLocalizedString("yes", comment: "")
        let no              = NSLocalizedString("no", comment: "")
        
        let alert = UIAlertView(title: alertTitle, message: alertMessage, delegate: delegate, cancelButtonTitle: no)
        alert.addButton(withTitle: yes)
        
        return alert
    }
    
    class func failedJoinStreamAlert() -> UIAlertView {
        let alertTitle      = NSLocalizedString("cant_join_stream_alert_title", comment: "")
        let alertMessage    = NSLocalizedString("cant_join_stream_alert_message", comment: "")
        let ok              = NSLocalizedString("ok", comment: "")
        
        let alertView = UIAlertView(title: alertTitle, message: alertMessage, delegate: nil, cancelButtonTitle: ok)
        return alertView
    }
    
    class func streamClosedAlert(_ delegate: UIAlertViewDelegate?) -> UIAlertView {
        let alertTitle      = NSLocalizedString("stream_close_alert_title", comment: "")
        let alertMessage    = NSLocalizedString("stream_close_alert_message", comment: "")
        let ok              = NSLocalizedString("ok", comment: "")
        
        let alertView = UIAlertView(title: alertTitle, message: alertMessage, delegate: delegate, cancelButtonTitle: ok)
        return alertView
    }
    
    class func notificationAlert(_ delegate: UIAlertViewDelegate?, userInfo: [AnyHashable: Any]) -> UIAlertView {
        let aps     = userInfo["aps"] as! NSDictionary
        let alert   = aps["alert"] as! NSDictionary
        let key     = alert["loc-key"] as! String
        let args    = alert["loc-args"] as! NSArray
        let name    = args[0] as! String
        let type    = userInfo["uni-type"] as! UInt
        
        let format      = NSLocalizedString(key, comment: "")
        let message: String
        if type == 0 { // share
            let title   = args[1] as! String
            message = NSString(format: format as NSString, name, title) as String
        } else { // live
            message = NSString(format: format as NSString, name) as String
        }
        
        let view        = NSLocalizedString("view", comment: "")
        let dismiss     = NSLocalizedString("dismiss", comment: "")
        
        let alertView = UIAlertView(title: nil, message: message, delegate: delegate, cancelButtonTitle: dismiss)
        alertView.addButton(withTitle: view)
        
        return alertView
    }
    
    class func sendMailErrorAlert() -> UIAlertView {
        let alertTitle      = NSLocalizedString("feddback_error_alert_title", comment: "")
        let alertMessage    = NSLocalizedString("feddback_error_alert_message", comment: "")
        let ok              = NSLocalizedString("ok", comment: "")
        
        let alertView = UIAlertView(title: alertTitle, message: alertMessage, delegate: nil, cancelButtonTitle: ok)
        return alertView
    }

    class func mailUnavailableErrorAlert() -> UIAlertView {
        let alertTitle      = NSLocalizedString("mail_unavailable_error_alert_title", comment: "")
        let alertMessage    = NSLocalizedString("mail_unavailable_error_alert_message", comment: "")
        let ok              = NSLocalizedString("ok", comment: "")
        
        let alertView = UIAlertView(title: alertTitle, message: alertMessage, delegate: nil, cancelButtonTitle: ok)
        return alertView
    }
    
    class func unsuccessfullPingAlert(_ message: String, delegate: UIAlertViewDelegate?) -> UIAlertView {
        let ok = NSLocalizedString("ok", comment: "")
        
        let alertView = UIAlertView(title: nil, message: message, delegate: delegate, cancelButtonTitle: ok)
        return alertView
    }
    
    class func notAuthorizedAlert(_ message: String) -> UIAlertView {
        let ok = NSLocalizedString("ok", comment: "")
        
        let alertView = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: ok)
        return alertView
    }
    
    class func userBlockedAlert() -> UIAlertView {
        let ok = NSLocalizedString("ok", comment: "")
        let message = NSLocalizedString("blocked_alert_message", comment: "")
        
        let alertView = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: ok)
        return alertView
    }
    
    class func alert( _ message: String) ->UIAlertView {
        let ok = NSLocalizedString("ok", comment: "")
        let alertView = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: ok)
        return alertView
    }
    
}

