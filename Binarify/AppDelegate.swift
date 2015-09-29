//
//  AppDelegate.swift
//  Binarify
//
//  Created by Nick on 26.08.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit

// Keys for NSUserDefaults
let encodingKey = "BINARIFY_ENCODING"
let whitespacesKey = "BINARIFY_WHITESPACES"
let autoCorrectionKey = "BINARIFY_AUTOCORRECTION"
let autoCopyingKey = "BINARIFY_AUTOCOPYING"
let appId = "912928467"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        return true
    }
    
//    func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
//        return true
//    }
//    
//    func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
//        return true
//    }

}

