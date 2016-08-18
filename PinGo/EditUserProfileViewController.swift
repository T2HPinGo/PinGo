//
//  EditUserProfileViewController.swift
//  PinGo
//
//  Created by Haena Kim on 8/12/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

@objc protocol EditUserProfileViewControllerDelegate {
    optional func editUserProfileViewController(editUserProfileViewController: EditUserProfileViewController, didUpdateProfile profile: [String:AnyObject])
}

class EditUserProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var profileImage: UIButton!
    
    @IBOutlet weak var profileBackgroundView: UIView!
    
    @IBOutlet weak var firstname: UILabel!
    @IBOutlet weak var lastname: UILabel!
    @IBOutlet weak var phonenumber: UILabel!
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    let imagePicker = UIImagePickerController()
    var isPaymentCollapsed = true
    var isHistoryCollapsed = true
    var isSubscriptionCollapsed = true
    weak var delegate: EditUserProfileViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        tableView.delegate = self
        //        tableView.dataSource = self
        
        logoutButton.backgroundColor = AppThemes.cellColors[2]
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        
        UserProfile.currentUser = nil
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.logout()
        
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
        
        profileImage.setImage(pickedImage, forState: .Normal)
        profileBackgroundView.backgroundColor = UIColor(patternImage: pickedImage!)
        
        let blurEffect = UIBlurEffect(style: .Light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = profileBackgroundView.bounds
        profileBackgroundView.addSubview(blurredEffectView)
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.clipsToBounds = true
        
        self.profileImage.layer.borderWidth = 0.4
        self.profileImage.layer.borderColor = UIColor.blackColor().CGColor
        
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
