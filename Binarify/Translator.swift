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
    
    private let binaryCharacters: [Character] = ["0", "1", " "]
    
    var encoding: Encoding
    var whitespacesEnabled: Bool
    
    init(encoding: Encoding, addsWhitespaces whitespacesEnabled: Bool) {
        self.encoding = encoding
        self.whitespacesEnabled = whitespacesEnabled
    }
    
    func translate(aString: String) -> String {
        var isBinary = true
        
        if aString.characters.count >= encoding.characterBitLength {
            let firstCharacterLetters = aString.substringToIndex(aString.startIndex.advancedBy(encoding.characterBitLength))
            for letter in firstCharacterLetters.characters {
                for _ in binaryCharacters {
                    if letter != "0" && letter != "1" && letter != " " {
                        isBinary = false
                    }
                }
            }
        } else {
            isBinary = false
        }
        
        return isBinary ? translateFromBinary(aString) : translateToBinary(aString)
    }
    
    private func translateToBinary(aString: String) -> String {
        var bytes = [String]()
        switch encoding {
        case .UTF8:
            for asciiNumber in aString.utf8 {
                let number: UInt32 = UInt32(asciiNumber)
                var byte = String(number, radix: 2)
                byte = pad(byte, toSize: 8)
                bytes.append(byte)
            }
        case .UTF16:
            for asciiNumber in aString.utf16 {
                let number: UInt32 = UInt32(asciiNumber)
                var byte = String(number, radix: 2)
                byte = pad(byte, toSize: 16)
                bytes.append(byte)
            }
            
        case .Unicode:
            for asciiNumber in aString.unicodeScalars {
                let number = asciiNumber.value
                var byte = String(number, radix: 2)
                byte = pad(byte, toSize: 32)
                bytes.append(byte)
            }
        }
        
        let separatorForJoining = whitespacesEnabled ? " " : ""
        let product = bytes.joinWithSeparator(separatorForJoining)
        
        return product
    }
    
    
    private func translateFromBinary(string: String) -> String {
        var charactersAsBinary = [String]()
        
        // Delete Whitespaces
        let clearBinary = string.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        clearBinary.characters.count
        clearBinary.characters.count / encoding.characterBitLength
        // Separate into Byte-Blocks
        for numberOfBytes in 0...(clearBinary.characters.count / encoding.characterBitLength) {
            charactersAsBinary.append(clearBinary.substring(numberOfBytes * encoding.characterBitLength, length: encoding.characterBitLength ))
        }
        
        let values = charactersAsBinary.map{ strtoul($0, nil, 2) }.map{ Int($0) }
        let characters = values.map{ String(UnicodeScalar(Int($0))) } as [String]
        return characters.joinWithSeparator("")
    }
    
    
    // MARK: - Helper Functions
    
    private func bitValueAtPosition(index: Int) -> Int {
        if index == 0 { return 1 }
        else { return Int(pow(2.0, Double(index))) }
    }
    
    private func bitValueAtPosition(index: Int) -> UInt32 {
        if index == 0 { return 1 }
        else { return UInt32(pow(2.0, Double(index))) }
    }
    
    private func pad(string : String, toSize: Int) -> String {
        var padded = string
        for _ in 0..<toSize - string.characters.count {
            padded = "0" + padded
        }
        return padded
    }

}