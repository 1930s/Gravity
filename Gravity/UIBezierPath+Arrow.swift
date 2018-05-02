//
//  UIBezierPath+Arrow.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 5/2/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

extension UIBezierPath {
    class func arrowShape(width: CGFloat, height: CGFloat, headWidthRatio: CGFloat, headHeightRatio: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let tailHeight = height - (height * headHeightRatio)
        let tailWidth = width - (width * headWidthRatio)
        let point1 = CGPoint(x: (width-tailWidth)/2.0, y: 0)
        let point2 = CGPoint(x: point1.x + tailWidth, y: point1.y)
        let point3 = CGPoint(x: point2.x, y: point2.y + tailHeight)
        let point4 = CGPoint(x: width, y: point3.y)
        let point5 = CGPoint(x: width/2, y: height)
        let point6 = CGPoint(x: 0, y: point4.y)
        let point7 = CGPoint(x: point1.x, y: point6.y)
        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.addLine(to: point4)
        path.addLine(to: point5)
        path.addLine(to: point6)
        path.addLine(to: point7)
        path.addLine(to: point1)
        path.close()
        path.apply(CGAffineTransform(translationX: -width/2, y: -height))
        return path
    }
}
