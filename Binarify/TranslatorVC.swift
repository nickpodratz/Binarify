//
//  ViewController.swift
//  Binarify
//
//  Created by Nick on 26.08.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit


class TranslatorController: UIViewController, UITextFieldDelegate {
                            
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
        NSTimer.scheduledTimerWithTimeInterval(2.8, target: self, selector: "animateBinarifyButton", userInfo: nil, repeats: false)
    }
    
    override func viewDidAppear(animated: Bool) {
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
    
    
    // MARK: - User Interaction
    
    @IBAction func copyToPasteboard(sender: AnyObject) {
        UIPasteboard.generalPasteboard().string = outputTextView.text
        performSegueWithIdentifier("toCopyingSucceededVC", sender: self)
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
    
    @IBAction func translate(sender: UITextField) {
        if sender.text != nil && !sender.text!.isEmpty {
            outputTextView.userInteractionEnabled = true
            outputTextView.text = translator.translate(sender.text!)
            copyButton.enabled = true
        } else {
            outputTextView.userInteractionEnabled = false
            outputTextView.text = nil
            copyButton.enabled = false
        }
    }
    
    // Transitioning
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { print("No Identifier specified."); return }
        
        switch identifier {
            
        case "toSettings":
            let destinationController = (segue.destinationViewController as! UINavigationController).visibleViewController as! SettingsController
            destinationController.delegate = self
            
        case "toCopyingSucceededVC": return

        default: print("Presenting View Controller with unknown segue \"\(segue.identifier)\"")
        }
    }
    
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
    
    @IBAction func returnsToViewController(segue:UIStoryboardSegue) {
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

extension TranslatorController: SettingsDelegate {
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
