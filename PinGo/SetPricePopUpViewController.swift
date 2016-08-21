//
//  SetPricePopUpViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/21/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class SetPricePopUpViewController: UIViewController {
    //MARK: - Outlets and Variables
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var priceTextField: UITextField!
    var ticket: Ticket?
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
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func close() {
      
        
    }
    
    @IBAction func okAction(sender: UIButton) {
        let jsonData = Worker.currentUser?.dataJson
        SocketManager.sharedInstance.applyTicket(jsonData!, ticketId: ticket!.id!, price: priceTextField.text!)
        dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: - Helpers
    func setupAppearance() {
       // popupView.layer.cornerRadius = 10
        view.backgroundColor = UIColor.clearColor()
        
    }
    
    func cornerRadiusForButton(button: UIButton) {
        button.layer.cornerRadius = button.frame.width / 2
        button.layer.backgroundColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 25.0/255.0, alpha: 1.0).CGColor
    }
    
}

//MARK: - EXTENSION - UIViewControllerTransitioningDelegat
extension SetPricePopUpViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController,
                                                          presentingViewController presenting: UIViewController,
                                                                                   sourceViewController source: UIViewController) -> UIPresentationController? {
        //tell the compiler to use DimmingPresentationController class instead of the standard presentation controller.
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

extension SetPricePopUpViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        //return true if user touch any where but the popupView
        return touch.view === self.view
    }
}

