//
//  TicketDetailViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/9/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

protocol TicketRatingViewControllerDelegate: class {
    func ticketRatingViewController(from: TicketRatingViewController, didRateTicket rating: String)
}

class TicketRatingViewController: UIViewController {
    //MARK: - Outlets and Variables
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var workerProfileImageView: UIImageView!
    @IBOutlet weak var workerNameLabel: UILabel!
    
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var badButton: UIButton!
    @IBOutlet weak var normalButton: UIButton!
    @IBOutlet weak var goodButton: UIButton!
    @IBOutlet weak var greatBUtton: UIButton!
    
    var rating: String? //store the string that corresponding to the rating icons
    
    weak var delegate: TicketRatingViewControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self  //if you dont't add this, the gradient view will not show up
    }
    
    //MARK: Load Views
    override func viewDidLoad() {
        super.viewDidLoad()

        //set up apperance
        setupAppearance()
        
        
        //add gesture so user can close the popup by tapping out side the popup view
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self //if dont add this line, it's just going to dismiss the popup anywhere user taps
        view.addGestureRecognizer(gestureRecognizer)
        
        //add the start stage for the animation of rating buttons
        let translate = CGAffineTransformMakeTranslation(0, 500)
        let scale = CGAffineTransformMakeScale(0.0, 0.0)
        badButton.transform = CGAffineTransformConcat(scale, translate)
        normalButton.transform = CGAffineTransformConcat(scale, translate)
        goodButton.transform = CGAffineTransformConcat(scale, translate)
        greatBUtton.transform = CGAffineTransformConcat(scale, translate)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       
        UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [], animations: {
            self.badButton.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [], animations: {
            self.normalButton.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [], animations: {
            self.goodButton.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [], animations: {
            self.greatBUtton.transform = CGAffineTransformIdentity
        }, completion: nil)
    }
    
    //MARK: - Actions
//    @IBAction func close() {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func ratingSelected(sender: UIButton) {
        switch sender.tag {
        case 100:
            rating = "dislike"
        case 200:
            rating = "rating"
        case 300:
            rating = "good"
        case 400:
            rating = "great"
        default:
            rating = "rating"
        }
        
        performSegueWithIdentifier("UnwindToHomeTimeline", sender: sender)
    }
    
    //MARK: - Helpers
    func setupAppearance() {
        popupView.layer.cornerRadius = 10
        view.backgroundColor = UIColor.clearColor()
        
        //rating buttons
        cornerRadiusForButton(badButton)
        cornerRadiusForButton(normalButton)
        cornerRadiusForButton(goodButton)
        cornerRadiusForButton(greatBUtton)
        
    }
    
    func cornerRadiusForButton(button: UIButton) {
        button.layer.cornerRadius = button.frame.width / 2
        button.layer.backgroundColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 25.0/255.0, alpha: 1.0).CGColor
        
    }

}

extension TicketRatingViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController,
                                                          presentingViewController presenting: UIViewController,
                                                        sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationViewController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController(presented: UIViewController,
                                                   presentingController presenting: UIViewController,
                                                    sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return T2HBounceAnimationController()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return T2HRotateOutAnimationController()
    }
}

extension TicketRatingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        //return true if user touch any where but the popupView
        return touch.view === self.view
    }
}
