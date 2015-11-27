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
        // Create an array of the characters' binary values contained in aString.
        let unpaddedBinaryStrings: [String] = {
            switch encoding {
            case .UTF8: return aString.utf8.map{ String($0, radix: 2) }
            case .UTF16: return aString.utf16.map{ String($0, radix: 2) }
            case .Unicode: return aString.unicodeScalars.map{ String($0.value, radix: 2) }
            }
        }()
        
        // Add padding to the values and join them together.
        return unpaddedBinaryStrings.reduce("") {
            initial, unpaddedBinaryString in
            let paddedByteString = pad(unpaddedBinaryString, toSize: encoding.characterBitLength)
            let separatorForJoining = whitespacesEnabled && !initial.isEmpty ? " " : ""
            return initial + separatorForJoining + paddedByteString
        }
    }
    
    
    private func translateFromBinary(string: String) -> String {
        // Delete Whitespaces
        let clearBinary = string.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        // Separate into Byte-Blocks
        var binaryCharacters = [String]()
        for numberOfBytes in 0...(clearBinary.characters.count / encoding.characterBitLength) {
            binaryCharacters.append(clearBinary.substring(numberOfBytes * encoding.characterBitLength, length: encoding.characterBitLength ))
        }
        
        let numericValues = binaryCharacters.map{ Int(strtoul($0, nil, 2)) }
        let characters = numericValues.map{ String(UnicodeScalar(Int($0))) }
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
    
    /// Recursively adds 0s as padding to the left of the input string
    private func pad(aString : String, toSize: Int) -> String {
        if toSize == aString.characters.count {
            return aString
        }
        return pad("0" + aString, toSize: toSize)
    }

}