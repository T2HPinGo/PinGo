//
//  HomeTimelineViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/3/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class HomeTimelineViewController: BaseViewController {
    //MARK: - Outlets and variables
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var createNewTicketButton: UIButton!

     //MARK: - Fake Data
    
    
    //MARK: - Load view
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create gesture to access UserProfileVC by tapping on the profile image
//        let ticket = Ticke
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions


    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    //MARK: Helpers

}

/*
//MARK: - EXTENSION UITableViewDataSource, UITableViewDelegate
extension HomeTimelineViewController: UITableViewDataSource, UITableViewDelegate {
    
}
 */
