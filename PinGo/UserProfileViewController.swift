//
//  UserProfileViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/4/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class UserProfileViewController: BaseViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var addProfileImage: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.backgroundColor = UIColor(red: 140/255.0, green: 0/255.0, blue: 40/255.0, alpha: 1.0)
//        self.view.backgroundColor = UIColor(red: 0.2, green: 0.1, blue: 0.2, alpha: 0.35)
//        backgroundImage.hidden = true
        // Do any additional setup after loading the view.
    }

    @IBAction func saveCliked(sender: AnyObject) {
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func maleCliked(sender: AnyObject) {
        addProfileImage.setImage(UIImage(named: "male"), forState: .Normal)
    }
    
    
    @IBAction func femaleCliked(sender: AnyObject) {
        addProfileImage.setImage(UIImage(named: "female"), forState: .Normal)
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
        
        dismissViewControllerAnimated(true, completion: nil)
        
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
