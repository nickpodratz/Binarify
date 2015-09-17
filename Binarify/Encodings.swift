//
//  Encodings.swift
//  Binarify
//
//  Created by Nick Podratz on 09.09.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import Foundation

enum Encoding: Int {
    case ASCII = 0
    case Latin1
    case UTF8
    
    func getDescription() -> String {
        switch self {
        case .ASCII: return "ASCII"
        case .Latin1: return "Latin-1"
        case .UTF8: return "UTF-8"
        }
    }
}