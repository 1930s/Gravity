//
//  PopUp.swift
//  Agenda
//
//  Created by Alexander Pagliaro on 12/1/17.
//  Copyright © 2017 Limit Point LLC. All rights reserved.
//

import UIKit

class PopUp: NSObject {
    
    /** Final frame for pop up */
    public var frame: CGRect = CGRect.zero
    
    /** Allow touches to pass through to these views */
    public var passthroughViews: [UIView] = []
    
    /** Presentation state */
    internal(set) public var isPresented: Bool = false
    
    // MARK: Internal
    internal var isPresenting: Bool = true
    internal var initiallyInteractive: Bool = false
    internal var isInteractive: Bool { return transitionContext?.isInteractive ?? false }
    internal var transitionAnimator: UIViewPropertyAnimator!
    internal var transitionContext: UIViewControllerContextTransitioning?
    internal var presentingViewController: UIViewController? {
        didSet {
            presentingViewControllerOriginalSuperview = presentingViewController?.view.superview
        }
    }
    internal var presentedViewController: UIViewController? {
        didSet {
            presentedViewController?.transitioningDelegate = self
            presentedViewController?.modalPresentationStyle = .custom
        }
    }
    internal var presentingViewControllerOriginalSuperview: UIView?
    internal var panGestureStartLocation: CGPoint?
    lazy var panGestureRecognizer: UIPanGestureRecognizer? = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized(recognizer:)))
        recognizer.delegate = self
        recognizer.cancelsTouchesInView = true
        return recognizer
    }()
    lazy internal var tapGestureRecognizer: UITapGestureRecognizer? = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(recognizer:)))
        recognizer.delegate = self
        return recognizer
    }()
    
    public func present(from location: CGPoint, preferredSize: CGSize) {
        frame = calculatePopupFrame(forLocation: location, popupSize: preferredSize)
        present()
    }
    
    public func present() {
        guard let viewController = presentedViewController else { return }
        presentingViewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func calculatePopupFrame(forLocation location: CGPoint, popupSize size: CGSize) -> CGRect {
        //  Check if there's room below to present popup, otherwise present above
        var y: CGFloat = 0.0
        var x: CGFloat = 0.0
        let touchOffset: CGFloat = 5.0
        if location.y + touchOffset + size.height < UIScreen.main.bounds.height {
            y = location.y + touchOffset
        } else {
            y = location.y - size.height - touchOffset
        }
        if y < touchOffset + 60.0 { y = touchOffset + 60.0 }
        if y > UIScreen.main.bounds.height + size.height + touchOffset { y = UIScreen.main.bounds.height - size.height - touchOffset }
        if location.x >= UIScreen.main.bounds.midX {
            x = location.x - touchOffset - size.width
        } else {
            x = location.x + touchOffset
        }
        if x < touchOffset { x = touchOffset }
        if x > UIScreen.main.bounds.width - size.width + touchOffset { x = UIScreen.main.bounds.width - size.width - touchOffset }
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
