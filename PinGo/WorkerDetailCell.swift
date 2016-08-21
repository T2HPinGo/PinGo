//
//  WorkerDetailCell.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/9/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire

class WorkerDetailCell: UITableViewCell {
    @IBOutlet weak var workerProfileImageView: UIImageView!
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var workerRatingLabel: UILabel!
    @IBOutlet weak var workerHourlyRateLabel: UILabel!
    var ticketBiddingController: TicketBiddingViewController?
    var ticket: Ticket?
    var worker: Worker! {
        didSet {
            workerNameLabel.text =  worker.username
            workerRatingLabel.text = String(format: "%.1f", worker.averageRating)
            workerHourlyRateLabel.text = worker.price
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAppearance()
    }
    
    @IBAction func onPickWorker(sender: AnyObject) {
        ticket?.worker = worker
        print("Pick WOrker: \(worker)")
        
        var parameters = [String:AnyObject]()
        parameters["idWorker"] = worker.id!
        parameters["nameOfWorker"] = worker.username!
        parameters["phoneNumber"] = worker.phoneNumber!
        parameters["imageOfWorker"] = (worker.profileImage?.imageUrl)!
        parameters["price"] = worker.price
        let url = "\(API_URL)\(PORT_API)/v1/ticket/\(ticket!.id!)"
        Alamofire.request(.POST, url, parameters: parameters).responseJSON { response  in
            print(response.result)
            let JSON = response.result.value!["data"] as! [String: AnyObject]
            self.ticket = Ticket(data: JSON)
            SocketManager.sharedInstance.pushCategory(JSON)
        }
    }
    
    //MARK: - Helpers
    func setupAppearance() {
        //profile image
        workerProfileImageView.layer.cornerRadius = workerProfileImageView.frame.width / 2
        workerProfileImageView.clipsToBounds = true
    }

    @IBAction func onprofileAction(sender: AnyObject) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "EditUserProfile", bundle: nil)
        
        let navigationController =
            storyBoard.instantiateViewControllerWithIdentifier("EditUserProfileNavigationController") as! UINavigationController
        let editUserProfileViewController = navigationController.topViewController as! EditUserProfileViewController
        
        editUserProfileViewController.userProfile = worker
        ticketBiddingController?.presentViewController(navigationController, animated: true, completion:nil)
    }

}
