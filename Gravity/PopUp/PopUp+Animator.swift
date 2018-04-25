//
//  PopUp+Animator.swift
//  Agenda
//
//  Created by Alexander Pagliaro on 12/1/17.
//  Copyright © 2017 Limit Point LLC. All rights reserved.
//

import UIKit

extension PopUp {
    func generateAnimator(_ animations: @escaping () -> Void, transitionCompletion: @escaping (UIViewAnimatingPosition) -> Void) -> UIViewPropertyAnimator {
        let duration = PopUp.animationDuration()
        let timingParameters = UISpringTimingParameters(dampingRatio: isPresenting ? 0.7 : 1.0, initialVelocity: CGVector(dx: 30.0, dy: 30.0))
        transitionAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)
        transitionAnimator.addAnimations(animations)
        transitionAnimator.addCompletion { [unowned self] (position) in
            transitionCompletion(position)
            let completed = (position == .end)
            self.transitionContext?.completeTransition(completed)
            self.transitionContext = nil
        }
        return transitionAnimator
    }
    
    class func animationDuration() -> TimeInterval {
        return 0.3
    }
    
    class func propertyAnimator(initialVelocity: CGVector = .zero) -> UIViewPropertyAnimator {
        let timingParameters = UISpringTimingParameters(mass: 4.5, stiffness: 1300, damping: 95, initialVelocity: initialVelocity)
        return UIViewPropertyAnimator(duration: 0.5, timingParameters:timingParameters)
    }
}
