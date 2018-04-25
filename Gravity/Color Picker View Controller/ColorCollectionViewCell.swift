//
//  ColorCollectionViewCell.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 4/25/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

@IBDesignable
class ColorView: UIView {
    @IBInspectable
    var color: UIColor = .black {
        didSet {
            self.backgroundColor = color
            self.setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.width/2.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = self.frame.width/10.0
    }
    
    override func draw(_ rect: CGRect) {
        if color == UIColor.clear {
            let line = UIBezierPath()
            line.move(to: .init(x: rect.minX, y: rect.maxY))
            line.addLine(to: .init(x: rect.maxX, y: rect.minY))
            line.lineWidth = self.layer.borderWidth
            UIColor.red.set()
            line.stroke()
        }
    }
}

class ColorCollectionViewCell: UICollectionViewCell {

    @IBOutlet var colorView: ColorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
