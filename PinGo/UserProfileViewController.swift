//
//  UserProfileViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/4/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire

class UserProfileViewController: BaseViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var fistname: SkyFloatingLabelTextField!
    @IBOutlet weak var lastname: SkyFloatingLabelTextField!
    @IBOutlet weak var username: SkyFloatingLabelTextField!
    @IBOutlet weak var email: SkyFloatingLabelTextField!
    
    @IBOutlet weak var phonenumber: SkyFloatingLabelTextField!
    
    @IBOutlet weak var isFemale: UISwitch!
    @IBOutlet weak var password: SkyFloatingLabelTextField!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var confirmpassword: SkyFloatingLabelTextField!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var addProfileImage: UIButton!
    
    @IBOutlet weak var signUpTextField: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    

    
    let imagePicker = UIImagePickerController()
    var user : UserProfile?
    
    let lightGreyColor = UIColor(red: 197/255, green: 205/255, blue: 205/255, alpha: 1.0)
    let darkGreyColor = UIColor(red: 52/255, green: 42/255, blue: 61/255, alpha: 1.0)
    let overcastBlueColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.signUpTextField.backgroundColor = AppThemes.redButtonColor
        
        backgroundImage.hidden = true
        
        scrollView.delegate = self
        textView.delegate = self
        
        phonenumber.keyboardType = UIKeyboardType.PhonePad
        password.secureTextEntry = true
        confirmpassword.secureTextEntry = true
        
        
        self.setupThemeColors(fistname)
        self.setupThemeColors(lastname)
        self.setupThemeColors(username)
        self.setupThemeColors(email)
        self.setupThemeColors(phonenumber)
        self.setupThemeColors(password)
        self.setupThemeColors(confirmpassword)
        
        self.errorLabel.textColor = UIColor.redColor()
        self.errorLabel.font = UIFont(name: "AppleSDGothicNeo-Light", size: 15)
        self.errorLabel.hidden = true
        
        user = UserProfile()
        scrollView.frame.size.height = 369
        
        //     self.scrollView.contentSize = CGSizeMake(375,900)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        let UITextViewTextDidEndEditingNotification: String
        
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor.blackColor().CGColor, UIColor.clearColor().CGColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField){
            scrollView.contentInset.bottom = 200
            scrollView.scrollIndicatorInsets.top = 200
    }
    
    func keyboardWillShow(notification: NSNotification) {
    }
    
    func keyboardWillHide(notification: NSNotification) {
    }
    
    func setupThemeColors(setTextField: SkyFloatingLabelTextField) {
        let placeholderName = setTextField.placeholder!
        setTextField.placeholder     = NSLocalizedString("* \(placeholderName)", tableName: "SkyFloatingLabelTextField", comment: "placeholder for person title field")
        setTextField.selectedTitle   = NSLocalizedString(placeholderName, tableName: "SkyFloatingLabelTextField", comment: "selected title for person title field")
        setTextField.title           = NSLocalizedString(placeholderName, tableName: "SkyFloatingLabelTextField", comment: "title for person title field")
        
        self.applySkyscannerTheme(setTextField)
        setTextField.delegate = self
    }
    
    func applySkyscannerTheme(textField: SkyFloatingLabelTextField) {
        
        textField.tintColor = UIColor.blueColor() //AppThemes.cellColors[4]
        
        textField.textColor = lightGreyColor
        textField.lineColor = lightGreyColor
        
        textField.selectedTitleColor = AppThemes.cellColors[4]
        textField.selectedLineColor = AppThemes.cellColors[4]
        
        
        
        //         Set custom fonts for the title, placeholder and textfield labels
        textField.titleLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
        textField.placeholderFont = UIFont(name: "AppleSDGothicNeo-Light", size: 15)
        textField.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func addProfileImage(sender: AnyObject) {
        print("camera on")
        
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.PhotoLibrary){
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .PhotoLibrary
            
            presentViewController(imagePicker, animated: true, completion: nil)
            
            //        self.performSegueWithIdentifier("tagSegue", sender: nil)
        }else{
            imagePicker.sourceType = .PhotoLibrary
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        //        let edittedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        
        addProfileImage.setImage(pickedImage, forState: .Normal)
        self.addProfileImage.layer.cornerRadius = self.addProfileImage.frame.size.width/2
        self.addProfileImage.clipsToBounds = true
        
        self.addProfileImage.layer.borderWidth = 0.2
        self.addProfileImage.layer.borderColor = UIColor.whiteColor().CGColor
        
        
        PinGoClient.uploadImage((user?.profileImage)!, image: pickedImage!, uploadType: "profile")
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func signUpAction(sender: AnyObject) {
        
        let parameters = [
            "username": username.text!,
            "password": password.text!,
            "firstname":fistname.text!,
            "lastname":lastname.text!,
            "email" : email.text!,
            "phoneNumber": phonenumber.text!,
            "imageUrl": "\((user?.profileImage?.imageUrl)!)",
            "width": "\((user?.profileImage?.width)!)",
            "height": "\((user?.profileImage?.height)!)",
            "isWorker": false,
            "isFemale":isFemale.on
        ]
        
        
        if let firstNameText = fistname.text, let lastNameText = lastname.text, let userNameText = username.text, let emailText = email.text, let phonenumberText = phonenumber.text, let passwordText = password.text, let confirmpasswordText = confirmpassword.text {
            if firstNameText == "" || lastNameText == "" || userNameText == "" || emailText == "" || phonenumberText == "" || passwordText == "" || confirmpasswordText == "" {
                print("the string is empty")
                self.errorLabel.hidden = false
                self.errorLabel.text = "Please fill in all of the required fields"
            } else if confirmpasswordText != passwordText {
                print("password not matched")
                self.errorLabel.hidden = false
                self.errorLabel.text = "Password does not match the confirm password"
            } else {
                
                Alamofire.request(.POST, "\(API_URL)\(PORT_API)/v1/register", parameters: parameters as?[String : AnyObject]).responseJSON { response  in
                    print(response)
                    
                    let JSON = response.result.value as? [String:AnyObject]
                    
                    let status = JSON!["status"] as? NSNumber
                    
                    
                    if status == 200{
                        let popup = UIAlertController(title: "Account Created", message: "Please log in with your new account", preferredStyle: UIAlertControllerStyle.Alert)
                        let action = UIAlertAction(title: "OK", style: .Default, handler: { _ in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                        self.presentViewController(popup, animated: true, completion: nil)
                        popup.addAction(action)
                        
                    } else {
                        let errorMessage = JSON!["message"] as! String
                        print(errorMessage)
                        self.errorLabel.hidden = false
                        self.errorLabel.text = errorMessage
                        
                    }
                    
                }
            }
        }
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
    
    @IBAction func onCancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
