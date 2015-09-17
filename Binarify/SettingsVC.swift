//
//  SettingsTableViewController.swift
//  Binarify
//
//  Created by Nick on 09.09.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import UIKit

protocol SettingsDelegate {
    func settingsController(didSetEncoding encoding: Encoding)
    func settingsController(didSetWhitespacesEnabled enabled: Bool)
    func settingsController(didSetAutoCorrection enabled: Bool)
    func settingsController(didSetAutoCopying enabled: Bool)
}

class SettingsController: UITableViewController, EncodingSelectorDelegate {
    
    @IBOutlet weak var encodingLabel: UILabel!
    @IBOutlet weak var whitespacesSwitch: UISwitch!
    @IBOutlet weak var wordSuggestionsSwitch: UISwitch!
    @IBOutlet weak var autoCopyingSwitch: UISwitch!
    
    var delegate: SettingsDelegate!
    
    
    override func viewWillDisappear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.synchronize()
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let encoding = Encoding(rawValue: defaults.integerForKey(encodingKey)) ?? Encoding.ASCII
        encodingLabel.text = encoding.getDescription()
        whitespacesSwitch.on = defaults.boolForKey(whitespacesKey) ?? true
        wordSuggestionsSwitch.on = defaults.boolForKey(autoCorrectionKey) ?? true
        autoCopyingSwitch.on = defaults.boolForKey(autoCopyingKey) ?? true
    }
    
    
    // MARK: - Transitioning

    @IBAction func cancelToSettingsViewController(segue:UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == nil { return }
        
        switch segue.identifier! {
        case "toEncodingSelection":
            let destinationController = segue.destinationViewController as! EncodingSelectionController
            let defaults = NSUserDefaults.standardUserDefaults()
            let encoding = Encoding(rawValue: defaults.integerForKey(encodingKey)) ?? Encoding.ASCII
            destinationController.selectedEncoding = encoding
            destinationController.delegate = self
        case "toAbout": return
//            let destinationController = segue.destinationViewController as! AboutController
        default: print("Presenting unknown View Controller \"\(segue.identifier)\"")
        }
    }
    
    
    // MARK: - User interaction
    
    @IBAction func setWhitespacesSetting(sender: UISwitch) {
        delegate.settingsController(didSetWhitespacesEnabled: sender.on)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: whitespacesKey)
    }
    
    @IBAction func setAutoCorrectionSetting(sender: UISwitch) {
        delegate.settingsController(didSetAutoCorrection: sender.on)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: autoCorrectionKey)
    }
    
    @IBAction func setAutoCopyingSetting(sender: UISwitch) {
        delegate.settingsController(didSetAutoCopying: sender.on)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: autoCopyingKey)
    }
    
    
    // MARK: - Encoding Selector Delegate
    
    func didSelectEncoding(newEncoding: Encoding) {
        encodingLabel.text = newEncoding.getDescription()
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(newEncoding.rawValue, forKey: encodingKey)
    }
    
}