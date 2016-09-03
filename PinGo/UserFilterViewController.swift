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
    @IBOutlet weak var workersFoundLabel: UILabel!
    @IBOutlet weak var numberOfWorkersFoundLabel: UILabel!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    
    @IBOutlet weak var distanceSegmentControll: UISegmentedControl!
    
    @IBOutlet weak var priceFromTextField: UITextField!
    @IBOutlet weak var priceToTextField: UITextField!
    
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var badButton: UIButton!
    @IBOutlet weak var normalButton: UIButton!
    @IBOutlet weak var goodButton: UIButton!
    @IBOutlet weak var greatBUtton: UIButton!
    
    var workerList: [Worker] = []
    var workerFilteredList: [Worker] = []
    
    struct NSUserDefaultKeys {
        static let tipControlSegmentIndex = "TipControlSegmentIndex"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self  //if you dont't add this, the gradient view will not show up
    }
    
    //MARK: Load Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        updateDisplayedLabels()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        
        distanceSegmentControll.selectedSegmentIndex = userDefaults.integerForKey(NSUserDefaultKeys.tipControlSegmentIndex)
        
        //add gesture so user can close the popup by tapping out side the popup view
        let closePopupGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        closePopupGestureRecognizer.cancelsTouchesInView = false
        closePopupGestureRecognizer.delegate = self //if dont add this line, it's just going to dismiss the popup anywhere user taps
        view.addGestureRecognizer(closePopupGestureRecognizer)
        
        //dismiss keyboard when user tap anywhere inside the popup view
        let dismissKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        popupView.addGestureRecognizer(dismissKeyboardGestureRecognizer)
        
        //add a button on top of the keyboard to dismiss the keyboard when tapped
        let customView = UIView(frame: CGRectMake(0, 0, view.frame.width, 30))
        let dismissKeyboardButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        dismissKeyboardButton.center = customView.center
        dismissKeyboardButton.setImage(UIImage(named: "keyboard"), forState: .Normal)
        dismissKeyboardButton.addTarget(self, action: #selector(dismissKeyboard), forControlEvents: .TouchUpInside)
        customView.addSubview(dismissKeyboardButton)
        customView.backgroundColor = UIColor.lightGrayColor()
        priceFromTextField.inputAccessoryView = customView
        priceToTextField.inputAccessoryView = customView
        
        //make the view slide up/down when keyboard presents
        let notification = NSNotificationCenter.defaultCenter()
        notification.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    
    //MARK: - Helpers
    func updateDisplayedLabels() {
        switch workerList.count {
        case 0:
            numberOfWorkersFoundLabel.text = "No"
            workersFoundLabel.text = "Worker Found"
        case 1:
            numberOfWorkersFoundLabel.text = "1"
            workersFoundLabel.text = "Worker Found"
        default:
            numberOfWorkersFoundLabel.text = "\(workerList.count)"
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        //add this if statement to avoid the view slide up twice when user tap on one textField when another is still active
        if self.view.frame.origin.y == 0 {
            if keyboardSize.height > popupViewHeightConstraint.constant - 206 {
                //if the board obstructs the textfield the move the view up, otherwise do nothing
                UIView.animateWithDuration(0.4, animations: {
                    self.view.frame.origin.y -= (keyboardSize.height - (self.popupViewHeightConstraint.constant - 206)) //206 is the distance from the top of the popupView to the bottom of the container view that contains two textfield
                })
            }
            
        } else {
            return
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        UIView.animateWithDuration(0.4, animations: {
            self.view.frame.origin.y = 0
        })

    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - Actions
    @IBAction func onDistanceSegmentControl(sender: UISegmentedControl) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(sender.selectedSegmentIndex, forKey: NSUserDefaultKeys.tipControlSegmentIndex)
        userDefaults.synchronize()
    }
    
    
    
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

