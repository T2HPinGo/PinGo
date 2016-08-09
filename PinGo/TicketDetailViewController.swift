//
//  TicketDetailViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/9/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class TicketDetailViewController: UIViewController {
    //MARK: - Outlets and Variables
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var workerProfileImageView: UIImageView!
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var ticketTittle: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self  //if you dont't add this, the gradient view will not show up
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set up apperance
        popupView.layer.cornerRadius = 10
        view.backgroundColor = UIColor.clearColor()
        
        //add gesture so user can close the popup by tapping out side the popup view
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self //if dont add this line, it's just going to dismiss the popup anywhere user taps
        view.addGestureRecognizer(gestureRecognizer)
        
        //fake
        ticketTittle.text = "I have a very long name title just to test if my auto layout is correct or not. It's not long enough, that's why I add this bit to make it longer"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Actions
    @IBAction func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension TicketDetailViewController: UIViewControllerTransitioningDelegate {
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

extension TicketDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        //return true if user touch any where but the popupView
        //
        return touch.view === self.view
    }
}
