//
//  PopUp+UIGestureRecognizer.swift
//  Agenda
//
//  Created by Alexander Pagliaro on 12/1/17.
//  Copyright © 2017 Limit Point LLC. All rights reserved.
//

import UIKit

extension PopUp: UIGestureRecognizerDelegate {
 
    @objc
    func tapGestureRecognized(recognizer: UITapGestureRecognizer) {
        guard isPresented else { return }
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UIPanGestureRecognizer
    @objc
    func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        guard isPresented else { return }
        switch recognizer.state {
        case .began:
            // pause if there's already an animation running
            if transitionContext != nil {
                pauseAnimation()
                return
            }
            // otherwise we've started a transition
            initiallyInteractive = true
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        default:
            break
        }
        updateInteraction(fromGestureRecognizer: recognizer)
    }
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let containerView = presentedViewController?.view.superview else { return false }
        let location = touch.location(in: containerView)
        return !frame.contains(location)
    }
    
}
