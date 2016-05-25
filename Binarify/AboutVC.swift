//
//  AboutViewController.swift
//
//  Created by Nick Podratz on 09.09.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

extension UITableView {
    func deselectAllRows(animated animated: Bool = true) {
        if let selectedIndexPaths = self.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                self.deselectRowAtIndexPath(indexPath, animated: animated)
            }
        }
    }
}

extension String {
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}


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
        self.tableView.estimatedRowHeight = 100
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(AboutViewController.getOtherApps), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.deselectAllRows()
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
        let userInitiatedPatch = dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
        
        dispatch_async(userInitiatedPatch) {
            // Fetch my other apps in a asynchronously
            
            let countryCode = NSLocalizedString("majCountryCode", comment: "")
            guard let url = NSURL(string: "https://itunes.apple.com/search?term=Nick+Podratz&media=software&country=\(countryCode)") else { print("Can't create URL."); return }
            NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
                
                do {
                    
                    guard let data = data else {
                        dispatch_async(mainPatch) {
                            self.otherAppsActivityIndicator.stopAnimating()
                            self.otherAppsErrorLabel.text = NSLocalizedString("NO_INTERNET_CONNECTION", comment: "No internet connection")
                            self.otherAppsErrorLabel.hidden = false
                        }
                        return
                    }
                    guard
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary,
                        let results = json["results"] as? [NSDictionary] where !results.isEmpty else {
                            self.otherAppsErrorLabel.text = NSLocalizedString("NO_DATA_FOUND", comment: "No data found")
                            self.otherAppsErrorLabel.hidden = false
                            return
                    }
                    
                    // Prevent current app from being displayed in where clause
                    let localBundleId = NSBundle.mainBundle().infoDictionary!["CFBundleIdentifier"] as? String
                    let scaleFactor = Int(UIScreen.mainScreen().scale)
                    for result in results where result["bundleId"] as? String != localBundleId {
                        if let
                            trackId = result["trackId"] as? Int,
                            appName = result["trackName"] as? String,
                            iconURLString = result["artworkUrl60"] as? String,
                            iconURL = NSURL(string: iconURLString.replace("60x60bb", withString: "\(60*scaleFactor)x\(60*scaleFactor)bb")),
                            iconData = NSData(contentsOfURL: iconURL),
                            icon = UIImage(data: iconData) {
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
        let countryCode = NSLocalizedString("minCountryCode", comment: "")
        if let iOSAppStoreURL = NSURL(string: "itms-apps://itunes.apple.com/\(countryCode)/app/id\(appId)") {
            UIApplication.sharedApplication().openURL(iOSAppStoreURL)
        }
        tableView.deselectAllRows()
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
        case (0, 1):
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let visitWebsiteLocalized = NSLocalizedString("VISIT_MY_WEBSITE", comment: "")
            alertController.addAction(UIAlertAction(title: visitWebsiteLocalized, style: UIAlertActionStyle.Default, handler: { action in
                if let url = NSURL(string: "http://www.podratz.de") {
                    UIApplication.sharedApplication().openURL(url)
                }
                tableView.deselectAllRows()
            }))
            let showFacebookPageLocalized = NSLocalizedString("VISIT_FACEBOOK_PAGE", comment: "")
            alertController.addAction(UIAlertAction(title: showFacebookPageLocalized, style: UIAlertActionStyle.Default, handler: { action in
                if let url = NSURL(string: "fb://profile/1515153398777652/") {
                    UIApplication.sharedApplication().openURL(url)
                }
                tableView.deselectAllRows()
            }))
            alertController.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.Cancel, handler: { action in
                tableView.deselectAllRows()
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
        case (1, 0):
            openInAppStore()
            tableView.deselectAllRows()
        case (1, 1):
            if MFMailComposeViewController.canSendMail() {
                self.composeMail()
                tableView.deselectAllRows()
            } else {
                let alertController = UIAlertController(title: NSLocalizedString("CAN_NOT_SEND_MAIL", comment: "Can't send mail"), message: NSLocalizedString("HINT_ON_MAIL_PREFERENCES", comment: "Make sure, that the information about your mail account in the system preferences are valid."), preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
                    tableView.deselectAllRows()
                }))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        default: return
            
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        
        if let myBirthday = NSCalendar.currentCalendar().dateWithEra(1, year: 1997, month: 2, day: 24, hour: 6, minute: 0, second: 0, nanosecond: 0) {
            return yearsFrom(myBirthday)
        }
        
        return nil
    }
    
}


// MARK: - Mail Compose View Controller Delegate
extension AboutViewController: MFMailComposeViewControllerDelegate {
    
    func composeMail() {
        let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
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
