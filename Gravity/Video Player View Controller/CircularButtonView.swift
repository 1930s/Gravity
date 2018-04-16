//
//  CircularButtonView.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 4/15/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

@IBDesignable
class CircularButtonView: UIView {
    
    @IBOutlet var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = nil
        button.layer.cornerRadius = button.frame.width/2.0
        button.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.7
        self.addParallaxMotionEffects(intensity: 5.0)
    }
}
