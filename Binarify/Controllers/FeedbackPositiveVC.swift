//
//  FeedbackPositiveViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 04.10.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit

class FeedbackPositiveViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func pressedOpenAppStore(sender: UIButton) {
        openInAppStore()
        NSTimer.scheduledTimerWithTimeInterval(0.35, target: self, selector: #selector(FeedbackPositiveViewController.toThankYouViewController), userInfo: nil, repeats: false)
    }
    
    func toThankYouViewController() {
        performSegueWithIdentifier("toThankYouViewController", sender: self)
    }
    
    private func openInAppStore() {
        if let iOSAppStoreURL = NSURL(string: "itms-apps://itunes.apple.com/de/app/id\(appId)") {
            UIApplication.sharedApplication().openURL(iOSAppStoreURL)
        }
    }

}
