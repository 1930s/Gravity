//
//  UIView+AddParallaxMotionEffects.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 4/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

extension UIView {
    func addParallaxMotionEffects(intensity parallaxIntensity: CGFloat) {
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -parallaxIntensity
        verticalMotionEffect.maximumRelativeValue = parallaxIntensity
        
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -parallaxIntensity
        horizontalMotionEffect.maximumRelativeValue = parallaxIntensity
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [verticalMotionEffect, horizontalMotionEffect]
        self.addMotionEffect(group)
    }
}
