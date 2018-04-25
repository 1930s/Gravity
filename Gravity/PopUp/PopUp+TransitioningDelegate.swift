//
//  PopUp+TransitioningDelegate.swift
//  Agenda
//
//  Created by Alexander Pagliaro on 12/1/17.
//  Copyright © 2017 Limit Point LLC. All rights reserved.
//

import UIKit

extension PopUp: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PopUpPresentationController(presentedViewController: presented, presenting: presenting, popUp: self)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self
    }
}

extension PopUp: UIViewControllerInteractiveTransitioning {
    
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        startAnimation()
        if !transitionContext.isInteractive {
            animate(.end)
        }
    }
    
    private func startAnimation() {
        guard let transitionContext = transitionContext else { return }
        let containerView = transitionContext.containerView
        let viewController = transitionContext.viewController(forKey: isPresenting ? .to : .from)!
        var scale: CGFloat = 1.0
        if isPresenting {
            containerView.addSubview(viewController.view)
            viewController.view.frame = transitionContext.finalFrame(for: viewController)
            viewController.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        } else {
            scale = 0.1
        }
        self.transitionAnimator = generateAnimator({
            viewController.view.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, transitionCompletion: { (position) in
            
        })
    }
    
    var wantsInteractiveStart: Bool {
        return initiallyInteractive
    }
    
    func updateInteraction(fromGestureRecognizer recognizer: UIPanGestureRecognizer) {
        pauseAnimation()
        guard let transitionContext = transitionContext else { return }
        switch recognizer.state {
        case .began:
            panGestureStartLocation = recognizer.location(in: recognizer.view)
        case .changed:
            let translationInView = recognizer.translation(in: recognizer.view)
            let distance = sqrt((translationInView.x * translationInView.x) + (translationInView.y * translationInView.y))
            var percentComplete: CGFloat = distance / 100.0
            percentComplete = max(percentComplete, 0.0)
            percentComplete = min(percentComplete, 1.0)
            transitionAnimator.fractionComplete = percentComplete
            transitionContext.updateInteractiveTransition(percentComplete)
            if let viewController = transitionContext.viewController(forKey: .from) {
                let startFrame = transitionContext.initialFrame(for: viewController)
                let newCenter = CGPoint(x: startFrame.midX + translationInView.x, y: startFrame.midY + translationInView.y)
                viewController.view.center = newCenter
            }
            
        case .ended, .cancelled:
            endInteraction(fromGestureRecognizer: recognizer)
        default:
            break
        }
    }
    
    func endInteraction(fromGestureRecognizer recognizer: UIPanGestureRecognizer) {
        let position = completionPosition(fromGestureRecognizer: recognizer)
        if position == .end {
            transitionContext?.finishInteractiveTransition()
        } else {
            transitionContext?.cancelInteractiveTransition()
        }
        if transitionContext != nil {
            let velocity = recognizer.velocity(in: transitionContext?.containerView)
            let velocityUnitVector = CGVector(dx: velocity.x / 100.0, dy: velocity.y / 100.0)
            animate(position, withVelocity: velocityUnitVector)
        } else {
            animate(position)
        }
    }
    
    private func completionPosition(fromGestureRecognizer recognizer: UIPanGestureRecognizer) -> UIViewAnimatingPosition {
        let velocity = recognizer.velocity(in: transitionContext?.containerView)
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        if magnitude > 0 {
            return .end
        }
        if transitionAnimator.fractionComplete >= 0.50 {
            return .end
        }
        return .start
    }
    
}

extension PopUp: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        print("animate transition")
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return transitionAnimator
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        initiallyInteractive = false
    }
    
    func pauseAnimation() {
        guard transitionContext != nil else { return }
        transitionAnimator.pauseAnimation()
        transitionContext?.pauseInteractiveTransition()
    }
    
    func animate(_ toPosition: UIViewAnimatingPosition, withVelocity velocity: CGVector?=nil) {
        guard transitionContext != nil else { return }
        transitionAnimator.isReversed = (toPosition == .start)
        if transitionAnimator.state == .inactive {
            transitionAnimator.startAnimation()
        } else {
            var timingParameters: UITimingCurveProvider?
            if let velocity = velocity {
                timingParameters = UISpringTimingParameters(dampingRatio: 1.0, initialVelocity: velocity)
            }
            transitionAnimator.continueAnimation(withTimingParameters: timingParameters, durationFactor: 0.5)
        }
    }
}
