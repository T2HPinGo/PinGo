//
//  T2HSlideDownAnimationController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 9/1/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import Foundation

class T2HSlideDownAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    //determine how long the animation is
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey), let containerView = transitionContext.containerView() {
            let duration = transitionDuration(transitionContext)
            
            UIView.animateWithDuration(duration, animations: { 
                fromView.transform = CGAffineTransformMakeTranslation(0, containerView.bounds.height)
                }, completion: { finised in
                    transitionContext.completeTransition(finised)
            })
        }
    }
}
