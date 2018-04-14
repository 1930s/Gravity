//
//  UIVerticallyCenteredTextView.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 4/13/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class UIVerticallyCenteredTextView: UITextView {
    override var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
}
