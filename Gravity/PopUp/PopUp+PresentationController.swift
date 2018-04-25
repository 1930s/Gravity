//
//  PopUp+PresentationController.swift
//  Agenda
//
//  Created by Alexander Pagliaro on 12/1/17.
//  Copyright © 2017 Limit Point LLC. All rights reserved.
//

import UIKit

internal class PopUpPresentationController: UIPresentationController {
    
    private var popUp: PopUp
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, popUp: PopUp) {
        self.popUp = popUp
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return popUp.frame
    }
    
    override var shouldPresentInFullscreen: Bool {
        return false
    }
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    override func presentationTransitionWillBegin() {
        // Add gesture recognizer
        //popUp.tapGestureRecognizer = UITapGestureRecognizer(target: , action: )
        guard let containerView = containerView else { return }
        if let panGesture = popUp.panGestureRecognizer {
            containerView.addGestureRecognizer(panGesture)
        }
        if let tapGesture = popUp.tapGestureRecognizer {
            containerView.addGestureRecognizer(tapGesture)
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed {
            popUp.isPresented = true
        } else {
            containerView?.removeFromSuperview()
            //popUp.presentingViewControllerOriginalSuperview?.addSubview(presentingViewController.view)
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            containerView?.removeFromSuperview()
            //popUp.presentingViewControllerOriginalSuperview?.addSubview(presentingViewController.view)
            popUp.isPresented = false
        }
    }
    
}
