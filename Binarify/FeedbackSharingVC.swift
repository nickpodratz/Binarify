//
//  FeedbackSharingVC.swift
//  Rhetorica
//
//  Created by Nick Podratz on 26.11.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit
import Social

class FeedbackSharingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        setupNavigationBar()
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "rewindsToMasterViewController" {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(0, forKey: masterVCLoadingCounterKey)
            defaults.synchronize()
        }
    }
    
    private func setupNavigationBar() {
        let transparentWhiteImage = UIImage(color: UIColor(white: 1, alpha: 0))
        navigationController?.navigationBar.shadowImage = transparentWhiteImage
        navigationController?.navigationBar.setBackgroundImage(transparentWhiteImage, forBarMetrics: UIBarMetrics.Default)
    }
    
    @IBAction func postToFacebookPressed(sender: UIButton) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let controller = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            let coutryCode = NSLocalizedString("minCountryCode", comment: "")
            let url = NSURL(string: "https://itunes.apple.com/\(coutryCode)/app/binarify/id912928467?mt=8")!
            controller.addURL(url)
            self.presentViewController(controller, animated:true, completion: nil)
        }
        else {
            print("no Facebook account found on device")
        }
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
