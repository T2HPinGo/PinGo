//
//  LoginViewController.swift
//  PinGo
//
//  Created by Haena Kim on 8/11/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
                print(JSON!["message"] as! String)
            
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
