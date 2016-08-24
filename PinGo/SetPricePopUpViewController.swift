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
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var priceTextField: UITextField!
    
    //locale currency
    let locale = NSLocale.currentLocale()
    
    var ticket: Ticket?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self  //if you dont't add this, the gradient view will not show up
    }
    
    //MARK: Load Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priceTextField.delegate = self
        
        //set up apperance
        setupAppearance()
        
        //add gesture so user can close the popup by tapping out side the popup view
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self //if dont add this line, it's just going to dismiss the popup anywhere user taps
        view.addGestureRecognizer(gestureRecognizer)
        
        //format currency for textfield
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .CurrencyStyle
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.locale = self.locale
        priceTextField.placeholder = currencyFormatter.stringFromNumber(0.00)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func okAction(sender: UIButton) {
        let jsonData = Worker.currentUser?.dataJson
        SocketManager.sharedInstance.applyTicket(jsonData!, ticketId: ticket!.id!, price: priceTextField.text!)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Helpers
    func setupAppearance() {
        viewContent.layer.cornerRadius = 10
        closeButton.layer.cornerRadius = closeButton.frame.size.width / 2
        closeButton.layer.masksToBounds = true
        closeButton.layer.borderColor = UIColor.whiteColor().CGColor
        closeButton.layer.borderWidth = 2
        confirmButton.layer.borderColor = UIColor.whiteColor().CGColor
        confirmButton.layer.borderWidth = 2
        confirmButton.layer.cornerRadius = 5
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

//MARK: - EXTENSION - Dismiss popup by tapping outside the popup view
extension SetPricePopUpViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        //return true if user touch any where but the popupView
        return touch.view === self.view
    }
}

//MARK: - EXTENSION - UITextFieldDelegate
extension SetPricePopUpViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .CurrencyStyle
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.locale = self.locale
        
        
        let currencySymbol = locale.objectForKey(NSLocaleCurrencySymbol)! as! String
        let startString = textField.text
        textField.text = ""
        textField.text = currencySymbol + startString!.stringByReplacingOccurrencesOfString(currencySymbol, withString: "")
        //
        return true
    }
    
    /*
    func textFieldDidEndEditing(textField: UITextField) {
        
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .CurrencyStyle
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.locale = self.locale
        
        //get the currency symbol
        let currencySymbol = self.locale.objectForKey(NSLocaleCurrencySymbol)! as! String
        
        //remove the unneccessary characters fromt the string textField
        //eg: $1,234.00 -> 1234
        //if you dont do this before calling stringFromNumber, the number will be nil -> crash
        let stringFormat = textField.text?.stringByReplacingOccurrencesOfString(currencySymbol, withString: "").stringByReplacingOccurrencesOfString(",", withString: "")
        let number = Double(stringFormat!)
        
        //if the stringFormat is empty put the textField back to tha place holder
        priceTextField.text = number != nil ? currencyFormatter.stringFromNumber(number!) : nil
    }*/

}

