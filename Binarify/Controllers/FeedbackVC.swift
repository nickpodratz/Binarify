//
//  FeedbackViewController.swift
//  Rhetorica
//
//  Created by Nick Podratz on 04.10.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        setupNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "rewindsToTranslatorViewController" {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(0, forKey: feedbackCounterKey)
            defaults.synchronize()
        }
    }
    
    private func setupNavigationBar() {
        let transparentWhiteImage = UIImage(color: UIColor(white: 1, alpha: 0))
        navigationController?.navigationBar.shadowImage = transparentWhiteImage
        navigationController?.navigationBar.setBackgroundImage(transparentWhiteImage, forBarMetrics: UIBarMetrics.Default)
    }

}
