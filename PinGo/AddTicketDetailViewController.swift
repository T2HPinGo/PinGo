//
//  AddTicketDetailViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/28/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import JTCalendar

class AddTicketDetailViewController: UIViewController {
    //MARK: - Outlets and Variables
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var popupViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var displayView: UIView!
    
    @IBOutlet weak var photosContainerView: UIView!
    @IBOutlet weak var photosContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var takePhotoView1: UIView!
    @IBOutlet weak var pickedImageView1: UIImageView!
    @IBOutlet weak var pickedImageView1HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var takePhotoView2: UIView!
    @IBOutlet weak var takePhotoView2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickedImageView2: UIImageView!
    @IBOutlet weak var pickedImageView2HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var takePhotoView3: UIView!
    @IBOutlet weak var pickedImageView3: UIImageView!
    @IBOutlet weak var pickedImageView3HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: T2HTextViewWithPlaceHolder!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    var image: UIImage?  //store image that picked
    var currentImage: Int! //store the index of current image picker
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self  //if you dont't add this, the gradient view will not show up
    }
    
    //MARK: Load Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        addGesture()
        
        //add gesture so user can close the popup by tapping out side the popup view
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self //if dont add this line, it's just going to dismiss the popup anywhere user taps
        view.addGestureRecognizer(gestureRecognizer)
        
        //move the popupView up when keboard appears
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Helpers
    func setupAppearance() {
        
        //photos container view
        photosContainerView.backgroundColor = UIColor.clearColor()
        
        //popup view
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
        view.backgroundColor = UIColor.clearColor()
        
        //auto resize image picker viewss depending on screen size
        let leftAndRightMargin: CGFloat = 35
        let photosLeftAndRightMargin: CGFloat = 5
        let distanceBetweenImages: CGFloat = 3
        let photosTopAndBottomMargin: CGFloat = 3
        popupViewWidthConstraint.constant = view.bounds.width - leftAndRightMargin*2
        takePhotoView2HeightConstraint.constant = (popupViewWidthConstraint.constant - photosLeftAndRightMargin*2 - distanceBetweenImages*2) / 3
        photosContainerViewHeightConstraint.constant = takePhotoView2HeightConstraint.constant + 2*photosTopAndBottomMargin
        popupViewHeightConstraint.constant = displayView.frame.height + photosContainerViewHeightConstraint.constant + 8 + titleTextField.frame.height + 8 + descriptionTextView.frame.height + 8 + confirmButton.frame.height + 10
        
        //takePhotoView1/2/3
        setupPhotoView(takePhotoView1)
        setupPhotoView(takePhotoView2)
        setupPhotoView(takePhotoView3)
        takePhotoView2.hidden = true
        takePhotoView3.hidden = true
        
        //titleTextField
        titleTextField.placeholder = "Title"
        titleTextField.font = AppThemes.helveticaNeueLight14
        titleTextField.layer.cornerRadius = 5
        titleTextField.layer.borderWidth = 1.0
        titleTextField.layer.borderColor = AppThemes.appColorTheme.CGColor
        titleTextField.tintColor = AppThemes.appColorTheme
        
        //descriptionTextField
        descriptionTextView.placeholder = "Enter Description (Optional)"
        descriptionTextView.backgroundColor = UIColor.clearColor()
        descriptionTextView.font = AppThemes.helveticaNeueLight14
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = AppThemes.appColorTheme.CGColor
        descriptionTextView.tintColor = AppThemes.appColorTheme
        
        //close button
        closeButton.layer.cornerRadius = closeButton.frame.size.width / 2
        closeButton.layer.masksToBounds = true
        closeButton.layer.borderColor = UIColor.whiteColor().CGColor
        closeButton.layer.borderWidth = 2
        
        //confirm button
        confirmButton.layer.cornerRadius = 10
        confirmButton.backgroundColor = AppThemes.appColorTheme
        confirmButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        confirmButton.titleLabel?.font = AppThemes.helveticaNeueLight15
    }
    
    func setupPhotoView(view: UIView) {
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = AppThemes.appColorTheme.CGColor
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.clearColor()
    }
    
    func showImagePicker(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.view == takePhotoView1 {
            currentImage = 1
        } else if gestureRecognizer.view == takePhotoView2 {
            currentImage = 2
        } else if gestureRecognizer.view == takePhotoView3 {
            currentImage = 3
        }
        pickPhotoTakingMethod()
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -120
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    //MARK: - Actions & Gestures
    func addGesture() {
        //add gesture for imagePicker
        let firstPhotoViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showImagePicker(_:)))
        takePhotoView1.addGestureRecognizer(firstPhotoViewGestureRecognizer)
        
        let secondPhotoViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showImagePicker(_:)))
        takePhotoView2.addGestureRecognizer(secondPhotoViewGestureRecognizer)
        
        let thirdPhotoViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showImagePicker(_:)))
        takePhotoView3.addGestureRecognizer(thirdPhotoViewGestureRecognizer)
    }
    
    @IBAction func onClose(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

//MARK: - EXTENSION: Image Picker
extension AddTicketDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhotoTakingMethod() {
        //check id camera is availabel, if yes then aske user to choose between taking a photo and choose in library
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            //if camera isn't available. let user choose from library
            choosePhotoFromLibrary()
        }
    }
    
    //promt a message asking user to choose to take photo from camera or choose from library
    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default) { _ in
            self.takePhotoWithCamera()
        }
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default) { _ in
            self.choosePhotoFromLibrary()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(takePhotoAction)
        alert.addAction(chooseFromLibraryAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if let image = image {
            showImage(image)
        }
        
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showImage(image: UIImage){
        switch currentImage {
        case 1:
            pickedImageView1.image = image
            //PinGoClient.uploadImage((self.newTicket?.imageOne)!, image: image, uploadType: "ticket") ////upload image to server to save it on server
            pickedImageView1HeightConstraint.constant = takePhotoView2HeightConstraint.constant
            takePhotoView2.hidden = false //make the second photo picker visible when the first one is already picked
            break
        case 2:
            pickedImageView2.image = image
            //PinGoClient.uploadImage((self.newTicket?.imageTwo)!, image: image, uploadType: "ticket")  ////upload image to server to save it on server
            takePhotoView3.hidden = false //make the third photo picker visible when the second one is already picked
            pickedImageView2HeightConstraint.constant = takePhotoView2HeightConstraint.constant
            break
        case 3:
            pickedImageView3.image = image
            //PinGoClient.uploadImage((self.newTicket?.imageThree)!, image: image, uploadType: "ticket") //upload image to server to save it on server
            pickedImageView3HeightConstraint.constant = takePhotoView2HeightConstraint.constant
            break
        default:
            break
        }
    }
}

//MARK: - EXTENSION: Animations for Popup View
extension AddTicketDetailViewController: UIViewControllerTransitioningDelegate {
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

extension AddTicketDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        //return true if user touch any where but the popupView
        return touch.view === self.view
    }
}
