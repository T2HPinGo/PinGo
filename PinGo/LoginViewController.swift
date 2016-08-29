//
//  LoginViewController.swift
//  PinGo
//
//  Created by Haena Kim on 8/11/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    //facebook login 
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    let lightGreyColor = UIColor(red: 197/255, green: 205/255, blue: 205/255, alpha: 1.0)
    let darkGreyColor = UIColor(red: 52/255, green: 42/255, blue: 61/255, alpha: 1.0)
    let overcastBlueColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //facebook login
        view.addSubview(loginButton)
        loginButton.center = view.center
        loginButton.delegate = self

        if let token = FBSDKAccessToken.currentAccessToken(){
            fetchProfile()
        }
        self.login.backgroundColor = AppThemes.redButtonColor
        self.login.layer.cornerRadius = 5
       
//        self.logoImage.layer.masksToBounds = false
//        self.logoImage.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//        self.logoImage.layer.cornerRadius = logoImage.frame.size.width/2
//        self.logoImage.clipsToBounds = true
//        
//        self.logoImage.layer.borderWidth = 0.2
//        self.logoImage.layer.borderColor = UIColor.whiteColor().CGColor
        passwordTextField.secureTextEntry = true
        usernameTextField.autocorrectionType = .No
        passwordTextField.autocorrectionType = .No
//        let backgroundImage = UIImage(named: "eco")
//        backgroundView.backgroundColor = UIColor(patternImage: backgroundImage!)
//        
//        let blurEffect = UIBlurEffect(style: .Dark)
//        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
//        blurredEffectView.frame = view.bounds
//        backgroundView.addSubview(blurredEffectView)
        
        self.setupThemeColors(usernameTextField)
        self.setupThemeColors(passwordTextField)
        // Do any additional setup after loading the view.
        self.errorLabel.textColor = UIColor.redColor()
        self.errorLabel.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor.blackColor().CGColor, UIColor.clearColor().CGColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        

    }
    
    func fetchProfile(){
        print("fetch profile")
        
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler { (connection, result, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            
            if let email = result["email"] as? String{
                print(email)
                
            }
        }
        
    }
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("completed login")
        fetchProfile()
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -250
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func setupThemeColors(setTextField: SkyFloatingLabelTextField) {
        
        if setTextField == usernameTextField {
            setTextField.placeholder     = NSLocalizedString("Username", tableName: "SkyFloatingLabelTextField", comment: "placeholder for person title field")
            setTextField.selectedTitle   = NSLocalizedString("Username", tableName: "SkyFloatingLabelTextField", comment: "selected title for person title field")
            setTextField.title           = NSLocalizedString("Username", tableName: "SkyFloatingLabelTextField", comment: "title for person title field")
        }else{
            setTextField.placeholder     = NSLocalizedString("Password", tableName: "SkyFloatingLabelTextField", comment: "placeholder for person title field")
            setTextField.selectedTitle   = NSLocalizedString("Password", tableName: "SkyFloatingLabelTextField", comment: "selected title for person title field")
            setTextField.title           = NSLocalizedString("Password", tableName: "SkyFloatingLabelTextField", comment: "title for person title field")
            
        }
        
        
        self.applySkyscannerTheme(setTextField)
        
        setTextField.delegate = self
    }
    
    func applySkyscannerTheme(textField: SkyFloatingLabelTextField) {

        textField.tintColor = AppThemes.appColorTheme

        
        textField.textColor = lightGreyColor
        textField.lineColor = lightGreyColor
        
        textField.selectedTitleColor = AppThemes.appColorTheme
        textField.selectedLineColor = AppThemes.appColorTheme

        
        // Set custom fonts for the title, placeholder and textfield labels
        textField.titleLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
        textField.placeholderFont = UIFont(name: "AppleSDGothicNeo-Light", size: 16)
        textField.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        let parameters = [
            "username": usernameTextField.text!,
            "password": passwordTextField.text!
        ]

        Alamofire.request(.POST, "\(API_URL)\(PORT_API)/v1/login", parameters: parameters).responseJSON { response  in
            

            let JSON = response.result.value as? [String:AnyObject]
            let status = JSON!["status"] as? NSNumber
            
            if status == 200{
                let JSONobj = JSON!["data"] as? [String: AnyObject]
                let isWorker = JSONobj!["isWorker"] as! Bool
                if !isWorker {
                    let user = UserProfile(data: JSONobj!)
                    UserProfile.currentUser = user
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let resultViewController =
                        storyBoard.instantiateViewControllerWithIdentifier("HomeTimelineViewController") as! HomeTimelineViewController
                    
                    self.presentViewController(resultViewController, animated: true, completion: nil)
                } else {
                    print("Worker")
                    let worker = Worker(data: JSONobj!)
                    Worker.currentUser = worker
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Worker", bundle: nil)
                    
                    let resultViewController =
                        storyBoard.instantiateViewControllerWithIdentifier("MainViewController") as! UITabBarController
                    
                    self.presentViewController(resultViewController, animated: true, completion:nil)
                }
                
            }else {
                let errorMessage = JSON!["message"] as! String
                print(errorMessage)
                self.errorLabel.hidden = false
                self.errorLabel.text = errorMessage
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
    
}
