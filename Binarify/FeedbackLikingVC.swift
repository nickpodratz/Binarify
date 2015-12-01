//
//  FeedbackLikingVC.swift
//  Rhetorica
//
//  Created by Nick Podratz on 26.11.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit

class FeedbackLikingViewController: UIViewController {
    
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
    
    @IBAction func showFacebookPagePressed(sender: UIButton) {
        if let url = NSURL(string: "fb://profile/1515153398777652/") {
            UIApplication.sharedApplication().openURL(url)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
