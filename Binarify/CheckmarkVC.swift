//
//  CheckmarkViewController.swift
//  Binarify
//
//  Created by Nick Podratz on 17.09.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class CheckmarkViewController: UIViewController {

    @IBOutlet var checkmarkView: CheckmarkView!

    override func viewDidAppear(animated: Bool) {
//        self.checkmarkView.animateCheckmark()
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "dismissViewController", userInfo: nil, repeats: false)
    }
    
    func dismissViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
