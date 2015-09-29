//
//  AboutViewController.swift
//
//  Created by Nick Podratz on 09.09.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI


class AboutViewController: UITableViewController, SKStoreProductViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var pictureDescriptionLabel: UILabel! {
        didSet{
            if let myAge = getMyAge() where pictureDescriptionLabel.text != nil {
                pictureDescriptionLabel.text = "\(myAge), \(pictureDescriptionLabel.text!)"
            }
        }
    }
    @IBOutlet weak var otherAppsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var otherAppsCollectionView: UICollectionView!
    @IBOutlet weak var otherAppsErrorLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var timer: NSTimer!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otherAppsCollectionView.delegate = self
        otherAppsCollectionView.dataSource = self
        storeProductController = SKStoreProductViewController()
        storeProductController.delegate = self
        
        imageView.layer.cornerRadius = imageView.bounds.size.width / 2
        imageView.layer.masksToBounds = true

        // Update size of cells
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 0

        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "getOtherApps", userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    
    // MARK: - Store Kit
    
    var storeProductController: SKStoreProductViewController!
    
    var otherApps: [(icon: UIImage, title: String, trackId: Int)]? {
        didSet{
            if otherApps != nil {
                otherAppsCollectionView.reloadData()
                otherAppsErrorLabel.hidden = (otherApps != nil)
            }
        }
    }
    
    func getOtherApps() {
        var returnData:[(icon: UIImage, title: String, trackId: Int)] = []
        
        // Define second thread
        let mainPatch = dispatch_get_main_queue()
        let userInitiatedPatch: dispatch_queue_t!
        if #available(iOS 8.0, *) {
            userInitiatedPatch = dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
        } else {
            userInitiatedPatch = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
            // Fallback on earlier versions
        }
        
        dispatch_async(userInitiatedPatch) {
            // Fetch my other apps in a asynchronously
            
            guard let url = NSURL(string: "https://itunes.apple.com/search?term=Nick+Podratz&media=software&country=DE") else { print("Can't create URL."); return }
            NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
                
                do {
                    
                    guard let data = data else {
                        dispatch_async(mainPatch) {
                            self.otherAppsActivityIndicator.stopAnimating()
                            self.otherAppsErrorLabel.text = "keine Internetverbindung"
                            self.otherAppsErrorLabel.hidden = false
                        }
                        return
                    }
                    guard
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary,
                        let results = json["results"] as? [NSDictionary] where !results.isEmpty else {
                            self.otherAppsErrorLabel.text = "Daten nicht gefunden"
                            self.otherAppsErrorLabel.hidden = false
                            return
                    }
                    
                    // Prevent current app from being displayed in where clause
                    let localBundleId = NSBundle.mainBundle().infoDictionary!["CFBundleIdentifier"] as? String
                    for result in results where result["bundleId"] as? String != localBundleId {
                        if let
                            trackId = result["trackId"] as? Int,
                            appName = result["trackName"] as? String,
                            iconURLString = result["artworkUrl60"] as? String,
                            iconURL = NSURL(string: iconURLString),
                            iconData = NSData(contentsOfURL: iconURL),
                            icon = UIImage(data: iconData)?.resize(CGSize(width: 60, height: 60)) {
                                returnData.append(icon: icon, title: appName, trackId: trackId)
                        }
                    }
                    dispatch_async(mainPatch) {
                        // On success
                        self.timer.invalidate()
                        self.otherApps = returnData.isEmpty ? nil : returnData
                        self.otherAppsActivityIndicator.stopAnimating()
                    }
                } catch let error as NSError {
                    dispatch_async(mainPatch) {
                        print(error)
                        self.otherAppsActivityIndicator.stopAnimating()
                        self.otherAppsErrorLabel.hidden = false
                    }
                }
                }.resume()
        }
    }
    
    func openAppStorePagewithIdentifier(identifier: Int) {
        self.otherAppsCollectionView.userInteractionEnabled = false
        
        let productInfoDict = [SKStoreProductParameterITunesItemIdentifier: [identifier]]
        storeProductController.loadProductWithParameters(productInfoDict) { result, error in
            if error != nil {
                print(error)
            }
        }
        self.navigationController?.presentViewController(self.storeProductController, animated: true) {
            self.otherAppsCollectionView.userInteractionEnabled = true
        }
    }
    
    private func openInAppStore() {
        if let iOSAppStoreURL = NSURL(string: "itms-apps://itunes.apple.com/de/app/id\(appId)") {
            UIApplication.sharedApplication().openURL(iOSAppStoreURL)
        }
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    
    // MARK: - SKStoreProductViewControllerDelegate
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        self.dismissViewControllerAnimated(true) {
            self.storeProductController = SKStoreProductViewController()
            self.storeProductController.delegate = self
        }
    }
    
    
    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            openInAppStore()
        case (1, 1):
            if MFMailComposeViewController.canSendMail() {
                self.composeMail()
            } else {
                if #available(iOS 8.0, *) {
                    let alertController = UIAlertController(title: "Can't send mail", message: "Make sure, that you entered valid information about your mail account in the system preferences.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    // Fallback on earlier versions
                    // TODO: Add Fallback
                }
            }
        default: return
        }
    }
    
    // MARK: - Collection View
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("OtherAppsCell", forIndexPath: indexPath) as! OtherAppsCell
        let entry = otherApps![indexPath.row] as (icon: UIImage, title: String, trackId: Int)
        cell.imageView.image = entry.icon
        cell.label.text = entry.title
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return otherApps?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        openAppStorePagewithIdentifier(otherApps![indexPath.row].trackId)
    }
    
    
    // MARK: - Helper Functions
    
    private func getMyAge() -> Int? {
        func yearsFrom(date:NSDate) -> Int{
            return NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: date, toDate: NSDate(), options: .MatchFirst).year
        }
        
        if #available(iOS 8.0, *) {
            if let myBirthday = NSCalendar.currentCalendar().dateWithEra(1, year: 1997, month: 2, day: 24, hour: 6, minute: 0, second: 0, nanosecond: 0) {
                return yearsFrom(myBirthday)
            }
        } else {
            let myBirthdayComponent = NSDateComponents()
            myBirthdayComponent.year = 1997
            myBirthdayComponent.month = 2
            myBirthdayComponent.day = 24
            myBirthdayComponent.timeZone = NSTimeZone(name: "UTC")
            if let myBirthday = NSCalendar.currentCalendar().dateFromComponents(myBirthdayComponent) {
                return yearsFrom(myBirthday)
                
            }
        }
        
        return nil
    }
    
}


// MARK: - Mail Compose View Controller Delegate
extension AboutViewController: MFMailComposeViewControllerDelegate {
    
    func composeMail() {
        let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
        let deviceModel = UIDevice.currentDevice().model
        let systemVersion = UIDevice.currentDevice().systemVersion
        let appName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
        
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setToRecipients(["nick.podratz.support@icloud.com"])
        picker.setSubject("\(appName) App Feedback")
        picker.setMessageBody("\n\n\n\n\n\n\n-------------------------\nSome details about my device:\n– \(deviceModel) with iOS \(systemVersion)\n– \(appName), version \(appVersion)", isHTML: false)
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
