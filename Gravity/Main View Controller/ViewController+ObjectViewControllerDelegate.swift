//
//  ViewController+ObjectViewControllerDelegate.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 6/9/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

extension ViewController: ObjectViewControllerDelegate {
    func objectViewController(didSelect object: Object) {
        resetCurrentObjectState()
        self.state.currentObject = object
        switch object.type {
        case .media:
            loadObjectMedia()
            presentImagePickerIfNecessary()
        default:
            break
        }
    }
    
    func objectViewController(didDelete object: Object) {
        guard let index = self.state.recentObjects.index(of: object) else { return }
        self.state.recentObjects.remove(at: index)
    }
}
