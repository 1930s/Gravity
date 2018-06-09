//
//  ObjectCollectionViewCell.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 5/3/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ObjectCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
    @IBOutlet var button: UIButton!
    var buttonAction: (UIButton) -> Void = { _ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        buttonAction(sender)
    }

}
