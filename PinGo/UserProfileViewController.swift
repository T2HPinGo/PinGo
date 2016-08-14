//
//  UserProfileViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/4/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire

class UserProfileViewController: BaseViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    let imagePicker = UIImagePickerController()
    var user : UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.backgroundColor = UIColor(red: 140/255.0, green: 0/255.0, blue: 40/255.0, alpha: 1.0)
        //        self.view.backgroundColor = UIColor(red: 0.2, green: 0.1, blue: 0.2, alpha: 0.35)
        //        backgroundImage.hidden = true
        // Do any additional setup after loading the view.
        
        user = UserProfile()
    }
    
    @IBAction func saveCliked(sender: AnyObject) {
        
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
    
    @IBAction func saveAction(sender: AnyObject) {
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
        
        Alamofire.request(.POST, "\(API_URL)/v1/register", parameters: parameters as?[String : AnyObject]).responseJSON { response  in
            print(response)
            
        }
          dismissViewControllerAnimated(true, completion: nil)
        
        
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
