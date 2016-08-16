//
//  LoginViewController.swift
//  PinGo
//
//  Created by Haena Kim on 8/11/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    let lightGreyColor = UIColor(red: 197/255, green: 205/255, blue: 205/255, alpha: 1.0)
    let darkGreyColor = UIColor(red: 52/255, green: 42/255, blue: 61/255, alpha: 1.0)
    let overcastBlueColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = AppThemes.cellColors[4]
        self.login.backgroundColor = AppThemes.cellColors[3]
        
        
        let backgroundImage = UIImage(named: "eco")
        backgroundView.backgroundColor = UIColor(patternImage: backgroundImage!)
        
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = view.bounds
        backgroundView.addSubview(blurredEffectView)
        
        self.setupThemeColors(usernameTextField)
        self.setupThemeColors(passwordTextField)
        // Do any additional setup after loading the view.
        self.errorLabel.textColor = UIColor.redColor()
        self.errorLabel.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
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
        
        textField.tintColor = AppThemes.cellColors[4]
        
        textField.textColor = lightGreyColor
        textField.lineColor = lightGreyColor
        
        textField.selectedTitleColor = AppThemes.cellColors[4]
        textField.selectedLineColor = AppThemes.cellColors[4]
        
        // Set custom fonts for the title, placeholder and textfield labels
        textField.titleLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
        textField.placeholderFont = UIFont(name: "AppleSDGothicNeo-Light", size: 15)
        textField.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15)
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
        
        Alamofire.request(.POST, "\(API_URL)/v1/login", parameters: parameters).responseJSON { response  in

            let JSON = response.result.value as? [String:AnyObject]
            let status = JSON!["status"] as? NSNumber
            
            if status == 200{
                let JSONobj = JSON!["data"] as? [String: AnyObject]
                let user = UserProfile(data: JSONobj!)
                print(user.email)
                UserProfile.currentUser = user
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                let resultViewController =
                storyBoard.instantiateViewControllerWithIdentifier("MainViewController") as! UITabBarController
                
                self.presentViewController(resultViewController, animated: true, completion: nil)
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
