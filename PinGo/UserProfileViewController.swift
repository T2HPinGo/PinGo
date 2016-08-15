//
//  UserProfileViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/4/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire

class UserProfileViewController: BaseViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var fistname: SkyFloatingLabelTextField!
    @IBOutlet weak var lastname: SkyFloatingLabelTextField!
    @IBOutlet weak var username: SkyFloatingLabelTextField!
    @IBOutlet weak var email: SkyFloatingLabelTextField!
    
    @IBOutlet weak var phonenumber: SkyFloatingLabelTextField!
    
    @IBOutlet weak var isFemale: UISwitch!
    @IBOutlet weak var password: SkyFloatingLabelTextField!
    
    @IBOutlet weak var confirmpassword: SkyFloatingLabelTextField!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var addProfileImage: UIButton!
    
    @IBOutlet weak var signUpTextField: UIButton!
    
    let imagePicker = UIImagePickerController()
    var user : UserProfile?
    
    let lightGreyColor = UIColor(red: 197/255, green: 205/255, blue: 205/255, alpha: 1.0)
    let darkGreyColor = UIColor(red: 52/255, green: 42/255, blue: 61/255, alpha: 1.0)
    let overcastBlueColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.signUpTextField.backgroundColor = AppThemes.cellColors[3]
        self.navigationController!.navigationBar.backgroundColor = AppThemes.cellColors[3]
        //        self.view.backgroundColor = UIColor(red: 0.2, green: 0.1, blue: 0.2, alpha: 0.35)
        //        backgroundImage.hidden = true
        
        
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = view.bounds
        backgroundImage.addSubview(blurredEffectView)
        
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
        
        uploadImage((user?.profileImage)!, image: pickedImage!)
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

        Alamofire.request(.POST, "\(API_URL)/v1/register", parameters: parameters as?[String : AnyObject]).responseJSON { response  in
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
    
    func uploadImage(imageResource: ImageResource, image: UIImage){
        Alamofire.upload(
            .POST,
            "\(API_URL)/v1/images/profile",
            multipartFormData: { multipartFormData in
                if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                    multipartFormData.appendBodyPart(data: imageData, name: "profileImage", fileName: "fileName.jpg", mimeType: "image/jpeg")
                }
                
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        print(response)
                        let JSON = response.result.value as? [String:AnyObject]
                        //print(JSON!["url"])
                        imageResource.imageUrl = JSON!["url"] as? String
                        print(imageResource.imageUrl)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
        )
        
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
