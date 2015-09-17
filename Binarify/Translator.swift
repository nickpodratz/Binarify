//
//  Translator.swift
//  Binarify
//
//  Created by Nick Podratz on 09.09.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import Foundation

// MARK: - Translator

class Translator {
    
    private let bitValues = [1, 2, 4, 8, 16, 32, 64, 128]
    private let bitValuesB = [64, 32, 16, 8, 4, 2, 1, 0]
    private let bitPosition = [7, 6, 5, 4, 3, 2, 1, 0]
    private let allowedElements = ["0", "1", " "]

    var encoding: Encoding
    var whitespacesEnabled: Bool
    
    init(encoding: Encoding, addsWhitespaces whitespacesEnabled: Bool) {
        self.encoding = encoding
        self.whitespacesEnabled = whitespacesEnabled
    }
    
    func translate(aString: String) -> String {
        var isBinary = true
        
        if aString.characters.count >= 8 {
            let firstEightLetters = aString.substringToIndex(aString.startIndex.advancedBy(8))
            for letter in firstEightLetters.characters {
                for _ in allowedElements {
                    if String(letter) != "0" && String(letter) != "1" && String(letter) != " " {
                        isBinary = false
                    }
                }
            }
        } else {
            isBinary = false
        }
        
        return isBinary ? translateFromBinary(aString) : translateToBinary(aString)
    }

    private func translateToBinary(astring: String) -> String {
        var product = ""
        for asciiNumber in astring.utf8 {
            var number = Int(asciiNumber)
            for currentBitPosition in bitPosition {
                if number - bitValues[currentBitPosition] >= 0 {
                    number -= bitValues[currentBitPosition]
                    product += "1"
                }else {
                    product += "0"
                }
            }
            
            if whitespacesEnabled {
                product += " "
            }
        }
        
        product = product.substringToIndex(product.startIndex.advancedBy(product.characters.count-1))
        
        return product
    }
    
    private func translateFromBinary(string: String) -> String {
        var product = ""
        var bytesArray = [String]()
        
        // lösche Leerzeichen
        let clearBinary = string.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        // Teile in Byte-Blöcke
        for numberOfBytes in 1...(clearBinary.characters.count / 8) {
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