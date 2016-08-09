//
//  T2HRotateOutAnimationController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/10/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class T2HRotateOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    //determine how long the animation is
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey),
            let containerView = transitionContext.containerView() {
            let duration = transitionDuration(transitionContext)
            
            UIView.animateWithDuration(duration, animations: { 
                fromView.center.y -= containerView.bounds.size.height
                //fromView.transform = CGAffineTransformMakeScale(0.3, 0.3)
                fromView.transform = CGAffineTransformMakeRotation(3.14)
            }, completion: { finished in
                    transitionContext.completeTransition(finished)
            })
        }
        
    }
}
