//
//  UserFilterViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 9/1/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class UserFilterViewController: UIViewController {
    //MARK: - Outlets and Variables
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var displayedDateLabel: UILabel!
    @IBOutlet weak var displayedTimeLabel: UILabel!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    
    @IBOutlet weak var workersFoundLabel: UILabel!
    
    @IBOutlet weak var numberOfWorkersFoundLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self  //if you dont't add this, the gradient view will not show up
    }
    
    //MARK: Load Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        
        //add gesture so user can close the popup by tapping out side the popup view
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self //if dont add this line, it's just going to dismiss the popup anywhere user taps
        view.addGestureRecognizer(gestureRecognizer)
        
        
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Helpers
    func setupAppearance() {
        view.backgroundColor = UIColor.clearColor()
        
        popupViewHeightConstraint.constant = view.bounds.height - 150 - 69 //69 is height of status bar and navigation bar, 150 is roughly the height of the subViews in MapViewController
        
        displayView.backgroundColor = AppThemes.appColorTheme
        
        numberOfWorkersFoundLabel.textColor = UIColor.whiteColor()
        numberOfWorkersFoundLabel.font = AppThemes.oswaldRegular17
        
        workersFoundLabel.textColor = UIColor.grayColor()
        workersFoundLabel.font = AppThemes.oswaldRegular17
        
        
    }
    
    //MARK: - Actions
}


//MARK: - EXTENSION: Animations for Popup View
extension UserFilterViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController,
                                                          presentingViewController presenting: UIViewController,
                                                                                   sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationViewController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController(presented: UIViewController,
                                                   presentingController presenting: UIViewController,
                                                                        sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return T2HSlideUpAnimationController()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return T2HSlideDownAnimationController()
    }
}

extension UserFilterViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        //return true if user touch any where but the popupView
        return touch.view === self.view
    }
}

