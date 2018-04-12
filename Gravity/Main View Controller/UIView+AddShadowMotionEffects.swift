//
//  UIView+AddShadowMotionEffects.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 4/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

extension UIView {
    func addShadowMotionEffects(intensity parallaxIntensity: CGFloat, radius: CGFloat) {
        let layer = self.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = radius
        //layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        
        // Set vertical shadow effect
        let verticalMotionEffect: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "layer.shadowOffset.height", type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -parallaxIntensity
        verticalMotionEffect.maximumRelativeValue = parallaxIntensity
        
        // Set vertical shadow opacity effect
        let verticalTransparencyEffect: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "layer.shadowOpacity", type: .tiltAlongVerticalAxis)
        verticalTransparencyEffect.minimumRelativeValue = -0.9
        verticalTransparencyEffect.maximumRelativeValue = 1.0
        
        // Set horizontal shadow effect
        let horizontalMotionEffect: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "layer.shadowOffset.width", type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -parallaxIntensity
        horizontalMotionEffect.maximumRelativeValue = parallaxIntensity
        
        // Set horizontal shadow opacity effect
        let horizontalTransparencyEffect: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "layer.shadowOpacity", type: .tiltAlongHorizontalAxis)
        horizontalTransparencyEffect.minimumRelativeValue = -0.9
        horizontalTransparencyEffect.maximumRelativeValue = 1.0
        
        // Create group to combine all effects
        let group = UIMotionEffectGroup()
        group.motionEffects = [verticalMotionEffect, verticalTransparencyEffect, horizontalMotionEffect, horizontalTransparencyEffect]
        
        // Add both effects to the label
        self.addMotionEffect(group)
    }
}
