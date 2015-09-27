//
//  CheckmarkView.swift
//  Binarify
//
//  Created by Nick Podratz on 17.09.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
@IBDesignable
class CheckmarkView: UIVisualEffectView {
    
    @IBOutlet var label: UILabel!
    var pathLayer: CAShapeLayer!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    
    */
    
    @IBInspectable var cornerRadius: CGFloat = 10 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = cornerRadius > 0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //// Checkmark Drawing
        let checkmarkPath = UIBezierPath()
        checkmarkPath.moveToPoint(CGPointMake(0, 25))
        checkmarkPath.addLineToPoint(CGPointMake(24.67, 50))
        checkmarkPath.addLineToPoint(CGPointMake(74, 0))
        
        pathLayer = CAShapeLayer()
        let insets = CGSize(width: 37, height: 39)
        pathLayer.frame = CGRect(
            x: self.bounds.origin.x + insets.width,
            y: self.bounds.origin.y + insets.height,
            width: self.bounds.size.width - insets.width * 2,
            height: self.bounds.size.height - insets.height * 2
        )
        pathLayer.path = checkmarkPath.CGPath
        pathLayer.strokeColor = self.label.textColor.CGColor
        pathLayer.fillColor = nil
        pathLayer.lineWidth = 5
        pathLayer.lineJoin = kCALineJoinRound
        pathLayer.lineCap = kCALineJoinRound
        pathLayer.lineJoin = kCALineJoinRound
        
        animateCheckmark()
    }
    
    func animateCheckmark() {
        if self.pathLayer != nil {
            self.layer.addSublayer(pathLayer)
            let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = 0.3
            pathAnimation.fromValue = 0
            pathAnimation.toValue = 1
            pathLayer.addAnimation(pathAnimation, forKey: "strokeEnd")
        }
    }
}