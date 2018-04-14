//
//  UIButton-BorderedStyle.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 4/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedButton: UIButton {
    
    @IBInspectable var borderWidth: CGFloat = 2.0 { didSet { update() }}
    @IBInspectable var cornerRadius: CGFloat = 8.0 { didSet { update() }}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        update()
    }
    
    private func update() {
        self.layer.borderColor = self.titleLabel?.textColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
}
