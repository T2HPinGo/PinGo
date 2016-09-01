//
//  T2HSlideUpAnimationController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 9/1/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class T2HSlideUpAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    //determine how long the animation is
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey),
            let containerView = transitionContext.containerView() {
            
            toView.frame = transitionContext.finalFrameForViewController(toViewController)
            containerView.addSubview(toView)
            toView.transform = CGAffineTransformMakeTranslation(0, containerView.bounds.height)
            
            let duration = transitionDuration(transitionContext)
            
            UIView.animateWithDuration(duration, animations: {
                toView.transform = CGAffineTransformIdentity
                }, completion: { finished in
                    transitionContext.completeTransition(finished)
            })
        }
    }
}
