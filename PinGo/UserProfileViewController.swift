//
//  UserProfileViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/4/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class UserProfileViewController: BaseViewController {


    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var addProfileImage: UIButton!
    
    
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
