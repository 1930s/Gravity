//
//  UIBezierPath+LocationSymbol.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 5/3/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

extension UIBezierPath {
    
    class func locationSymbol() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 236.5, y: 128))
        bezierPath.addCurve(to: CGPoint(x: 213, y: 133.54), controlPoint1: CGPoint(x: 228.05, y: 128), controlPoint2: CGPoint(x: 220.07, y: 129.99))
        bezierPath.addCurve(to: CGPoint(x: 184, y: 180.5), controlPoint1: CGPoint(x: 195.81, y: 142.16), controlPoint2: CGPoint(x: 184, y: 159.95))
        bezierPath.addCurve(to: CGPoint(x: 236.5, y: 233), controlPoint1: CGPoint(x: 184, y: 209.49), controlPoint2: CGPoint(x: 207.51, y: 233))
        bezierPath.addCurve(to: CGPoint(x: 289, y: 180.5), controlPoint1: CGPoint(x: 265.49, y: 233), controlPoint2: CGPoint(x: 289, y: 209.49))
        bezierPath.addCurve(to: CGPoint(x: 236.5, y: 128), controlPoint1: CGPoint(x: 289, y: 151.51), controlPoint2: CGPoint(x: 265.49, y: 128))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 388, y: 193))
        bezierPath.addCurve(to: CGPoint(x: 236, y: 474), controlPoint1: CGPoint(x: 388, y: 298), controlPoint2: CGPoint(x: 236, y: 474))
        bezierPath.addCurve(to: CGPoint(x: 85, y: 193), controlPoint1: CGPoint(x: 236, y: 474), controlPoint2: CGPoint(x: 85, y: 303))
        bezierPath.addCurve(to: CGPoint(x: 86.12, y: 172.97), controlPoint1: CGPoint(x: 85, y: 186.04), controlPoint2: CGPoint(x: 85.38, y: 179.37))
        bezierPath.addCurve(to: CGPoint(x: 236, y: 43), controlPoint1: CGPoint(x: 96.98, y: 78.1), controlPoint2: CGPoint(x: 184.48, y: 43))
        bezierPath.addCurve(to: CGPoint(x: 388, y: 193), controlPoint1: CGPoint(x: 291, y: 43), controlPoint2: CGPoint(x: 388, y: 88))
        bezierPath.close()
        return bezierPath
    }
    
}
