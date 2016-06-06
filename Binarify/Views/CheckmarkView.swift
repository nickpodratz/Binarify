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
    var pathLayer: CheckmarkLayer!
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
        layoutCheckmark()
        //        pathLayer.color = self.label.textColor.CGColor

        
    }
    
    private func layoutCheckmark() {
        pathLayer = CheckmarkLayer()
        pathLayer.frame = CGRect(
            x: self.bounds.width/4,
            y: self.bounds.height/4,
            width: self.bounds.width/2,
            height: self.bounds.height/3
        )
        self.layer.addSublayer(pathLayer)
        pathLayer.animate()
    }

}


class CheckmarkPath: UIBezierPath {
    
    /// Draw a UIBezierPath in the specified rectangle.
    init(rect: CGRect) {
        super.init()
        drawCheckmarkInRect(rect)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func drawCheckmarkInRect(rect: CGRect) {
        moveToPoint(CGPointMake(rect.origin.x, rect.size.height/2))
        addLineToPoint(CGPointMake(rect.size.width/3, rect.size.height))
        addLineToPoint(CGPointMake(rect.size.width, rect.origin.y))
    }
}

class CheckmarkLayer: CAShapeLayer {
    
    var color: UIColor = UIColor.blackColor() {
        didSet {
            strokeColor = color.CGColor
        }
    }
    
    override var frame: CGRect {
        didSet{
            super.frame = frame
            setupLayer()
        }
    }
    
    override var bounds: CGRect {
        didSet{
            super.bounds = bounds
            setupLayer()
        }
    }
    
    private func setupLayer() {
        path = CheckmarkPath(rect: bounds).CGPath
        strokeColor = color.CGColor
        fillColor = nil
        lineWidth = 5
        lineJoin = kCALineJoinRound
        lineCap = kCALineJoinRound
    }
    
    func animate() {
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 0.3
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        self.addAnimation(pathAnimation, forKey: "strokeEnd")
    }
    
}