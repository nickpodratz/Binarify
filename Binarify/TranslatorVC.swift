//
//  ViewController.swift
//  Binarify
//
//  Created by Nick on 26.08.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit
import MBProgressHUD
import PKHUD


let masterVCLoadingCounterKey = "MASTERVIEWCONTROLLERLOADINGKEY"

class TranslatorViewController: UIViewController, UITextFieldDelegate {
                            
    @IBOutlet weak var binarifyButton: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var outputTextView: UITextView!
    @IBOutlet var copyButton: UIButton!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    var autoCopying: Bool = NSUserDefaults.standardUserDefaults().boolForKey(autoCopyingKey)
    var translator: Translator!
    
    var lastTranslatedText: String?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        setupTextField()
        setupTranslator()
        NSTimer.scheduledTimerWithTimeInterval(2.8, target: self, selector: #selector(TranslatorViewController.animateBinarifyButton), userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(TranslatorViewController.checkForFeedbackViewControllers), userInfo: nil, repeats: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.textField.keyboardType = translator.encoding.keyboard
    }
    
    private func setupTranslator() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let encodingRaw = defaults.integerForKey(encodingKey)
        let encoding = Encoding(rawValue: encodingRaw) ?? Encoding.UTF8
        let whitespacesEnabled = defaults.boolForKey(whitespacesKey) ?? true
        self.translator = Translator(encoding: encoding, addsWhitespaces: whitespacesEnabled)
    }
    
    private func setupTextField() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let correctionEnabled = defaults.boolForKey(autoCorrectionKey) ?? false
        self.textField.autocorrectionType = correctionEnabled ? .Yes : .No
        self.textField.delegate = self
    }
    
    func checkForFeedbackViewControllers() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let counter = NSUserDefaults.standardUserDefaults().integerForKey(masterVCLoadingCounterKey) ?? 0
        
        print(counter)
        switch counter {
        case 5: performSegueWithIdentifier("toFeedback", sender: self)
        case 10: performSegueWithIdentifier("toFeedbackLiking", sender: self)
        case 15: performSegueWithIdentifier("toFeedbackSharing", sender: self)
        default: ()
        }
        
        defaults.setInteger(counter.successor(), forKey: masterVCLoadingCounterKey)
        defaults.synchronize()
    }
    

    // MARK: - User Interaction
    
    @IBAction func copyToPasteboard(sender: AnyObject) {
        UIPasteboard.generalPasteboard().string = outputTextView.text
        
        let checkmarkLayer = CheckmarkLayer()
        if #available(iOS 8.0, *) {
            let view = PKHUDSubtitleView(subtitle: NSLocalizedString("COPIED", comment: "Text in 'copied' HUD"), image: nil)
            view.layer.addSublayer(checkmarkLayer)
            PKHUD.sharedHUD.contentView = view
            PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
            PKHUD.sharedHUD.dimsBackground = false
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay: 1.0)
            checkmarkLayer.frame = CGRect(
                x: view.bounds.width/4,
                y: view.bounds.height/4,
                width: view.bounds.width/2,
                height: view.bounds.height/3
            )
            checkmarkLayer.animate()
        } else {
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.customView = UIView(frame: CGRect(x: 0, y: 0, width: 130, height: 110))
            hud.customView.layer.addSublayer(checkmarkLayer)
            hud.mode = MBProgressHUDMode.CustomView
            checkmarkLayer.frame = CGRect(
                x: hud.customView.bounds.width/4,
                y: hud.customView.bounds.width/4,
                width: hud.customView.bounds.width/2,
                height: hud.customView.bounds.width/3
            )
            hud.color = UIColor(white: 0.95, alpha: 1)
            hud.labelColor = UIColor.blackColor()
            checkmarkLayer.color = UIColor.blackColor()
            hud.labelText = "Added"
            hud.userInteractionEnabled = false
            hud.hide(true, afterDelay: 1)
            checkmarkLayer.animate()
        }
    }
    
    @IBAction func finishedEditing(sender: AnyObject) {
        textField.resignFirstResponder()
        tapGestureRecognizer.enabled = false
        if autoCopying && !textField.text!.isEmpty && textField.text != lastTranslatedText {
            lastTranslatedText = textField.text
            copyToPasteboard(sender)
        }
    }
    
    func animateBinarifyButton() {
        if self.binarifyButton != nil {
            let originalColor = self.binarifyButton.tintColor
            if self.presentedViewController == nil {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut,
                    animations: {
                        self.binarifyButton.transform = CGAffineTransformScale(self.binarifyButton.transform, 1.05, 1.05)
                        self.binarifyButton.tintColor = UIColor(red: 256/256, green: 170/256, blue: 0, alpha: 1)
                    }
                    ,
                    completion: { completed -> Void in
                        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.35, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseIn,
                            animations: {
                                self.binarifyButton.tintColor = originalColor
                                self.binarifyButton.transform = CGAffineTransformScale(self.binarifyButton.transform, 0.9375, 0.9375)
                            }, completion: nil)
                    }
                )                
            }
        }
    }
    
    @IBAction func translate(sender: UITextField) {
        if sender.text != nil && !sender.text!.isEmpty {
            outputTextView.userInteractionEnabled = true
            if let text = translator.translate(sender.text!) {
                outputTextView.text = text
                copyButton.enabled = true
            } else {
                self.textField.text = nil
                let alertController = UIAlertController(title: NSLocalizedString("wrong_encoding", comment: ""), message: NSLocalizedString("wrong_encoding_description", comment: ""), preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("wrong_encoding_button_title", comment: ""), style: .Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                copyButton.enabled = false
            }
        } else {
            outputTextView.userInteractionEnabled = false
            outputTextView.text = nil
            copyButton.enabled = false
        }
    }
    
    // MARK: - Transitioning
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { print("No Identifier specified."); return }
        
        switch identifier {
            
        case "toSettings":
            let destinationController = (segue.destinationViewController as! UINavigationController).visibleViewController as! SettingsViewController
            destinationController.delegate = self
            
        case "toCopyingSucceededVC": return
        case "toFeedback": return

        default: print("Presenting View Controller with unknown segue \"\(segue.identifier)\"")
        }
    }
    
    @IBAction func rewindsToTranslatorViewController(segue:UIStoryboardSegue) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(TranslatorViewController.checkForFeedbackViewControllers), userInfo: nil, repeats: false)
    }

    
    // MARK: Text Field Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        finishedEditing(textField)
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        tapGestureRecognizer.enabled = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.finishedEditing(textField)
    }
    
    
    // MARK: - State Preservation
  
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        coder.encodeObject(textField.text, forKey: "inputString")
        coder.encodeObject(outputTextView.text, forKey: "outputString")
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        textField.text = coder.decodeObjectForKey("inputString") as? String
        outputTextView.text = coder.decodeObjectForKey("outputString") as! String
        super.decodeRestorableStateWithCoder(coder)
    }

}

extension TranslatorViewController: SettingsDelegate {
    func settingsController(didSetEncoding encoding: Encoding) {
        self.translator.encoding = encoding
        self.textField.keyboardType = encoding.keyboard
        translate(textField)
    }
    
    func settingsController(didSetWhitespacesEnabled enabled: Bool) {
        self.translator.whitespacesEnabled = enabled
        translate(textField)
    }
    
    func settingsController(didSetAutoCorrection enabled: Bool) {
        self.textField.autocorrectionType = enabled ? .Yes : .No
    }
    
    func settingsController(didSetAutoCopying enabled: Bool) {
        self.autoCopying = enabled
        // Set auto copying enabled.
    }
    
    
}
