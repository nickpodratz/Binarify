//
//  ViewController.swift
//  Binarify
//
//  Created by Nick on 26.08.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let subStart = advance(self.startIndex, r.startIndex, self.endIndex)
            let subEnd = advance(subStart, r.endIndex - r.startIndex, self.endIndex)
            return self.substringWithRange(Range(start: subStart, end: subEnd))
        }
    }
    func substring(from: Int) -> String {
        let end = count(self)
        return self[from..<end]
    }
    func substring(from: Int, length: Int) -> String {
        let end = from + length
        return self[from..<end]
    }
}

class ViewController: UIViewController {
                            
    @IBOutlet var textField: UITextField!
    @IBOutlet var outputTextView: UITextView!
    @IBOutlet var copyButton: UIButton!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    let bitValues = [1, 2, 4, 8, 16, 32, 64, 128]
    let bitValuesB = [64, 32, 16, 8, 4, 2, 1, 0]
    let bitPosition = [7, 6, 5, 4, 3, 2, 1, 0]
    let allowedElements = ["0", "1", " "]
    
    
    override func viewDidLoad() {
        // From storyboard not working...
        let touchRecognizer = UITapGestureRecognizer(target: self, action: "finishedEditing:")
        self.view.addGestureRecognizer(touchRecognizer)
    }
    // MARK: - User Interaction
    
    @IBAction func copyToPasteboard(sender: AnyObject) {
        UIPasteboard.generalPasteboard().string = outputTextView.text
    }
    
    @IBAction func finishedEditing(sender: AnyObject) {
        textField.resignFirstResponder()
    }
    
    @IBAction func translate(sender: AnyObject) {
        
        if count(textField.text) != 0 {
            var isBinary = true
            
            if count(textField.text) >= 8 {
                let firstEightLetters = textField.text.substringToIndex(advance(textField.text.startIndex, 8))
                for letter in firstEightLetters {
                    for allowed in allowedElements {
                        if String(letter) != "0" && String(letter) != "1" && String(letter) != " " {
                            isBinary = false
                        }
                    }
                }
            } else {
                isBinary = false
            }
            
            outputTextView.text = isBinary ? translateFromBinary(textField.text) : translateToBinary(textField.text)
            copyButton.enabled = true
            
        } else {
            outputTextView.text = ""
            copyButton.enabled = false
        }
        
    }
    

    // // MARK: - State Preservation
  
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        println("encoding...")
        super.encodeRestorableStateWithCoder(coder)
        coder.encodeObject(textField.text, forKey: "inputString")
        coder.encodeObject(outputTextView.text, forKey: "outputString")
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        println("decoding...")
        super.decodeRestorableStateWithCoder(coder)
        textField.text = coder.decodeObjectForKey("inputString") as! String
        outputTextView.text = coder.decodeObjectForKey("outputString") as! String
    }
    
    
    // MARK: - Translator
    
    func translateToBinary(textField: String) -> String {
        var product = ""
        for asciiNumber in textField.utf8 {
            var number = Int(asciiNumber)
            for currentBitPosition in bitPosition {
                if number - bitValues[currentBitPosition] >= 0 {
                    number -= bitValues[currentBitPosition]
                    product += "1"
                }else {
                    product += "0"
                }
            }
            
            product += " "
            
        }
        
        product = product.substringToIndex(advance(product.startIndex, count(product)-1))

        return product
    }

    func translateFromBinary(textField: String) -> String {
        var product = ""
        var bytesArray = [String]()
        
        // lösche Leerzeichen
        let clearBinary = textField.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)

        // Teile in Byte-Blöcke
        for numberOfBytes in 1...(count(clearBinary) / 8) {
            bytesArray.append(clearBinary.substring(numberOfBytes * 8 - 7, length: 8 ))
        }
        
        // Code zum Übersetzen der Bytes in ASCII
        for currentByte in bytesArray {
            var asciiNumber = 0
            for currentBitPosition in 0...7 {
                if currentByte.substring(currentBitPosition, length: 1) == "1" {
                    asciiNumber += bitValuesB[currentBitPosition]
                }
            }
        product += String(UnicodeScalar(asciiNumber))
        }

        return product
    }

}
