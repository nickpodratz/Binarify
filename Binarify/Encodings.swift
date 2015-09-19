//
//  Encodings.swift
//  Binarify
//
//  Created by Nick Podratz on 09.09.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import UIKit

enum Encoding: Int {
    case UTF8 = 0
    case UTF16
    case Unicode
    
    func getDescription() -> String {
        switch self {
        case .UTF8: return "UTF-8"
        case .UTF16: return "UTF16"
        case .Unicode: return "Unicode Scalar"
        }
    }
    
    var characterBitLength: Int {
        switch self {
        case .UTF8: return 8
        case .UTF16: return 16
        case .Unicode: return 32
        }
    }
    
    var encodingStyle: UInt {
        switch self {
        case .UTF8: return NSUTF8StringEncoding
        case .UTF16: return NSUTF16BigEndianStringEncoding
        case .Unicode: return NSUTF32StringEncoding
        }
    }
    
    var keyboard: UIKeyboardType {
        switch self {
        case .UTF8: return UIKeyboardType.ASCIICapable
        case .UTF16: return UIKeyboardType.Default
        case .Unicode: return UIKeyboardType.Default
        }
    }
}