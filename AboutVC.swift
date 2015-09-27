//
//  AboutViewController.swift
//  Binarify
//
//  Created by Nick Podratz on 09.09.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI


class AboutController: UITableViewController, SKStoreProductViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var otherAppsTVCell: UITableViewCell!
    @IBOutlet weak var otherAppsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var otherAppsCollectionView: UICollectionView!
    @IBOutlet weak var otherAppsErrorLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    var selectedIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otherAppsCollectionView.delegate = self
        otherAppsCollectionView.dataSource = self
        otherAppsActivityIndicator.startAnimating()
        getOtherApps(excludeRunningApplication: true)
        storeProductController = SKStoreProductViewController()
        storeProductController.delegate = self
        
        imageView.layer.cornerRadius = imageView.bounds.size.width / 2
        imageView.layer.masksToBounds = true
        
        // Update size of cells
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 0
    }

    override func viewWillAppear(animated: Bool) {
        if selectedIndexPath != nil {
            tableView.deselectRowAtIndexPath(selectedIndexPath!, animated: true)
            selectedIndexPath = nil
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
        
    
    // MARK: - Store Kit
    
    var storeProductController: SKStoreProductViewController!
    
    var otherApps: [(icon: UIImage, title: String, trackId: Int)]? {
        didSet{
            otherAppsTVCell.hidden = false
            otherAppsCollectionView.reloadData()
            if otherAppsActivityIndicator != nil {
                otherAppsActivityIndicator.stopAnimating()
                otherAppsActivityIndicator.removeFromSuperview()
            }
            if otherAppsErrorLabel != nil {
                otherAppsErrorLabel.removeFromSuperview()
            }
        }
    }
    
    func getOtherApps(excludeRunningApplication excludeRunningApplication: Bool) {
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
            
            let url = NSURL(string: "http://itunes.apple.com/search?term=Nick+Podratz&media=software&country=DE")
            NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
                
                // Handle errors
                if error != nil {
                    print(error)
                    self.otherAppsActivityIndicator.stopAnimating()
                    self.otherAppsErrorLabel.hidden = false
                } else {
                    guard let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary else { return }
                    if let results = json["results"] as? [NSDictionary] {
                            
                            resultLoop: for result in results {
                                if excludeRunningApplication {
                                    // Check if app is running application
                                    if result["bundleId"] as? String == NSBundle.mainBundle().infoDictionary!["CFBundleIdentifier"] as? String {
                                        continue resultLoop
                                    }
                                }
                                
                                if let
                                    trackId = result["trackId"] as? Int,
                                    appName = result["trackName"] as? String,
                                    iconURLString = result["artworkUrl60"] as? String,
                                    iconURL = NSURL(string: iconURLString),
                                    iconData = NSData(contentsOfURL: iconURL),
                                    image = UIImage(data: iconData) {
                                        let icon = image.resize(CGSize(width: 60, height: 60))
                                        returnData.append(icon: icon, title: appName, trackId: trackId)
                                }
                            }
                    }
                }
                
                dispatch_async(mainPatch) {
                    self.otherApps = returnData.isEmpty ? nil : returnData
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
        if selectedIndexPath != nil {
            tableView.deselectRowAtIndexPath(selectedIndexPath!, animated: true)
            selectedIndexPath = nil
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
        selectedIndexPath = indexPath

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
        default: print("selected row \(indexPath)")
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

}


// Sending Feedback
extension AboutController: MFMailComposeViewControllerDelegate {
    
    func composeMail() {
        let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
        let deviceModel = UIDevice.currentDevice().model
        let systemVersion = UIDevice.currentDevice().systemVersion
        
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setToRecipients(["nick.podratz.support@icloud.com"])
        picker.setSubject("Binarify App Feedback")
        picker.setMessageBody("\n\n\n\n\n\n\n-------------------------\nSome details about my device:\n– \(deviceModel) with iOS \(systemVersion)\n– Binarify, version \(appVersion)", isHTML: false)
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
