//
//  Extensions.swift
//  Binarify
//
//  Created by Nick Podratz on 09.09.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import UIKit

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let subStart = self.startIndex.advancedBy(r.startIndex, limit: self.endIndex)
            let subEnd = subStart.advancedBy(r.endIndex - r.startIndex, limit: self.endIndex)
            return self.substringWithRange(Range(start: subStart, end: subEnd))
        }
    }
    func substring(from: Int) -> String {
        let end = self.characters.count
        return self[from..<end]
    }
    func substring(from: Int, length: Int) -> String {
        let end = from + length
        return self[from..<end]
    }
}

extension UIImage {
    func resize(newSize: CGSize) -> UIImage {
        let image = self
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(newSize, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: newSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext() // !!!
        return scaledImage
    }
    
    convenience init?(color: UIColor) {
        self.init(color: color, size: CGSizeMake(1, 1))
    }
    
    convenience init?(color: UIColor, size: CGSize) {
        let rect = CGRect(origin: CGPointZero, size: size)
        
        UIGraphicsBeginImageContext(size);
        //        let path = UIBezierPath(rect: rect)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.init(CGImage: image.CGImage!)
    }

}
