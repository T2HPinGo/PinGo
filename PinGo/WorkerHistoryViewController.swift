//
//  WorkerHistoryViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/9/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class WorkerHistoryViewController: UIViewController {
    @IBOutlet weak var workerProfileImageView: UIImageView!
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var workerAgeLabel: UILabel!
    
    @IBOutlet weak var numberOfTicketsDoneLabel: UILabel!

    @IBOutlet weak var workerRatingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    
    @IBAction func onPickWorker(sender: UIButton) {
    }
    

}
