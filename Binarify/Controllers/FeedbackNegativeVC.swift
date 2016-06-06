//
//  FeedbackNegativeViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 04.10.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit
import MessageUI

class FeedbackNegativeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }

    @IBAction func pressedComposeMail(sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            composeMail()
        } else {
            if #available(iOS 8.0, *) {
                let alertController = UIAlertController(title: NSLocalizedString("MAIL_COMPOSING_ERROR", comment: ""), message: NSLocalizedString("MAIL_COMPOSING_ERROR_DESCRIPTION", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

// MARK: - Mail Compose View Controller Delegate
extension FeedbackNegativeViewController: MFMailComposeViewControllerDelegate {
    
    func composeMail(completion: (() -> Void)? = nil) {
        let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
        let deviceModel = UIDevice.currentDevice().model
        let systemVersion = UIDevice.currentDevice().systemVersion
        let appName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
        
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setToRecipients(["nick.podratz.support@icloud.com"])
        picker.setSubject("\(appName) App Feedback")
        picker.setMessageBody("\n\n\n\n\n\n\n------------------------------------\nSome details about my device:\n– \(deviceModel) with iOS \(systemVersion)\n– \(appName), version \(appVersion)", isHTML: false)
        
        presentViewController(picker, animated: true, completion: completion)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true) {
            if result == MFMailComposeResultSent {
                self.performSegueWithIdentifier("toThankYouViewController", sender: self)
            }
        }
    }
    
}
