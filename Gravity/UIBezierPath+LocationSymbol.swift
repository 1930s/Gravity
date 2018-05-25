//
//  UIBezierPath+LocationSymbol.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 5/3/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

extension UIBezierPath {
    
    class func locationSymbol(scale: CGFloat=1.0) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0.5, y: -53))
        bezierPath.addCurve(to: CGPoint(x: -23, y: -47.46), controlPoint1: CGPoint(x: -7.95, y: -53), controlPoint2: CGPoint(x: -15.93, y: -51.01))
        bezierPath.addCurve(to: CGPoint(x: -52, y: -0.5), controlPoint1: CGPoint(x: -40.19, y: -38.84), controlPoint2: CGPoint(x: -52, y: -21.05))
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: 52), controlPoint1: CGPoint(x: -52, y: 28.49), controlPoint2: CGPoint(x: -28.49, y: 52))
        bezierPath.addCurve(to: CGPoint(x: 53, y: -0.5), controlPoint1: CGPoint(x: 29.49, y: 52), controlPoint2: CGPoint(x: 53, y: 28.49))
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: -53), controlPoint1: CGPoint(x: 53, y: -29.49), controlPoint2: CGPoint(x: 29.49, y: -53))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 152, y: 12))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 293), controlPoint1: CGPoint(x: 152, y: 117), controlPoint2: CGPoint(x: 0, y: 293))
        bezierPath.addCurve(to: CGPoint(x: -151, y: 12), controlPoint1: CGPoint(x: 0, y: 293), controlPoint2: CGPoint(x: -151, y: 122))
        bezierPath.addCurve(to: CGPoint(x: -149.88, y: -8.03), controlPoint1: CGPoint(x: -151, y: 5.04), controlPoint2: CGPoint(x: -150.62, y: -1.63))
        bezierPath.addCurve(to: CGPoint(x: 0, y: -138), controlPoint1: CGPoint(x: -139.02, y: -102.9), controlPoint2: CGPoint(x: -51.52, y: -138))
        bezierPath.addCurve(to: CGPoint(x: 152, y: 12), controlPoint1: CGPoint(x: 55, y: -138), controlPoint2: CGPoint(x: 152, y: -93))
        bezierPath.close()
        bezierPath.apply(CGAffineTransform(scaleX: scale, y: scale))
        return bezierPath
    }
    
}
