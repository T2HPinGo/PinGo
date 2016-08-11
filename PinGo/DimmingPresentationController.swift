//
//  DimmingPresentationController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/9/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class DimmingPresentationViewController: UIPresentationController {
    lazy var dimmingView = T2HGradientView(frame: CGRect.zero)
    
    //invoke when the new VC is about to show on the screen
    override func presentationTransitionWillBegin() {
        dimmingView.frame = (containerView?.bounds)!
        containerView?.insertSubview(dimmingView, atIndex: 0)
        
        //animation for dimming view along with animation for popupview
        dimmingView.alpha = 0
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ _ in
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        //make fade out animation for dimming when the popup us dimissed
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ _ in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
    
    
    override func shouldRemovePresentersView() -> Bool {
        //return false to keep the HomeTimelineViewControlelr visible when TicketDetailVC pops up (see thru effect)
        return false
    }
}
