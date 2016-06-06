//
//  RoundedButton.swift
//  Connect
//
//  Created by Nick Podratz on 10.09.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import UIKit
import CoreGraphics

@IBDesignable
class RoundedButton: UIButton {
        
    @IBInspectable var cornerRadius: CGFloat = 5 {
        didSet{
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = cornerRadius > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet{
            self.layer.borderColor = borderColor.CGColor
        }
    }
}
