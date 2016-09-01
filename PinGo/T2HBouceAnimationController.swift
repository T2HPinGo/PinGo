//
//  T2HBouceAnimationController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/10/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class T2HBounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    //determine how long the animation is
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {        
        if let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey),
            let containerView = transitionContext.containerView() {
            
            toView.frame = transitionContext.finalFrameForViewController(toViewController)
            containerView.addSubview(toView)
            toView.transform = CGAffineTransformMakeScale(0.6, 0.6)
            
            let duration = transitionDuration(transitionContext)
            
            UIView.animateKeyframesWithDuration(duration, delay: 0, options: .CalculationModeCubic, animations: {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.334, animations: { 
                    toView.transform = CGAffineTransformMakeScale(1.2, 1.2)
                })
                UIView.addKeyframeWithRelativeStartTime(0.334, relativeDuration: 0.333, animations: { 
                    toView.transform = CGAffineTransformMakeScale(0.9, 0.9)
                })
                UIView.addKeyframeWithRelativeStartTime(0.667, relativeDuration: 0.333, animations: { 
                    toView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                })
            }, completion: { finished in
                    transitionContext.completeTransition(finished)
            })
        }
        
    }
}
