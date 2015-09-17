//
//  ViewController.swift
//  Binarify
//
//  Created by Nick on 26.08.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit


class TranslatorController: UIViewController, UITextFieldDelegate {
                            
    @IBOutlet var textField: UITextField!
    @IBOutlet var outputTextView: UITextView!
    @IBOutlet var copyButton: UIButton!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    var translator: Translator!
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        setupTextField()
        setupTranslator()
    }
    
    private func setupTranslator() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let encodingRaw = defaults.integerForKey(encodingKey)
        let encoding = Encoding(rawValue: encodingRaw) ?? Encoding.ASCII
        let whitespacesEnabled = defaults.boolForKey(whitespacesKey) ?? true
        self.translator = Translator(encoding: encoding, addsWhitespaces: whitespacesEnabled)
    }
    
    private func setupTextField() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let correctionEnabled = defaults.boolForKey(autoCorrectionKey) ?? false
        self.textField.autocorrectionType = correctionEnabled ? .Yes : .No
    }
    

    // MARK: - User Interaction
    
    @IBAction func copyToPasteboard(sender: UIButton) {
        UIPasteboard.generalPasteboard().string = outputTextView.text
    }
    
    @IBAction func finishedEditing(sender: AnyObject) {
        textField.resignFirstResponder()
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
        if segue.identifier == nil { return }
        
        switch segue.identifier! {
        case "toSettings":
            let destinationController = (segue.destinationViewController as! UINavigationController).visibleViewController as! SettingsController
            destinationController.delegate = self
        default: print("Presenting unknown View Controller \"\(segue.identifier)\"")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        finishedEditing(textField)
        return false
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
    }
    
    func settingsController(didSetWhitespacesEnabled enabled: Bool) {
        self.translator.whitespacesEnabled = enabled
        translate(textField)
    }
    
    func settingsController(didSetAutoCorrection enabled: Bool) {
        self.textField.autocorrectionType = enabled ? .Yes : .No
    }
    
    func settingsController(didSetAutoCopying enabled: Bool) {
        // Set auto copying enabled.
    }
    
    
}
