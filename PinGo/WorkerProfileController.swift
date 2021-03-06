//
//  UserProfileController.swift
//  PinGo
//
//  Created by Cao Thắng on 8/15/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class WorkerProfileController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        Worker.currentUser = nil
        
        NSNotificationCenter.defaultCenter().postNotificationName(Worker.userDidLogOutNotification, object: nil)
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
