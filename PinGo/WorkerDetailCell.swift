//
//  WorkerDetailCell.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/9/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire

protocol WorkerDetailCellDelegate {
    func selectedMarker(marker: GMSMarker)
}

class WorkerDetailCell: UITableViewCell {
    @IBOutlet weak var workerProfileImageView: UIImageView!
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var workerRatingLabel: UILabel!
    
    @IBOutlet weak var buttonDistance: UIButton!
    
    @IBOutlet weak var workerHourlyRateLabel: UILabel!
    var mapViewController: MapViewController?
    var distance: Double? {
        didSet {
          let formartDistance = String(format:"%.2f km", distance!)
          buttonDistance.setTitle(formartDistance, forState: .Normal)
        }
    }
    var ticket: Ticket?
    var marker: GMSMarker?
    var delegate: WorkerDetailCellDelegate?
    var worker: Worker! {
        didSet {
            workerNameLabel.text =  worker.username
            //workerRatingLabel.text = String(format: "%.1f", worker.averageRating)
            workerHourlyRateLabel.text = worker.price
            
            if worker?.profileImage?.imageUrl! != "" {
                let profileUser = worker?.profileImage?.imageUrl
                HandleUtil.loadImageViewWithUrl(profileUser!, imageView: workerProfileImageView)
                workerProfileImageView.layer.cornerRadius = 5
                workerProfileImageView.clipsToBounds = true
            } else {
                workerProfileImageView.image = UIImage(named: "profile_default")
            }

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
        mapViewController?.presentViewController(navigationController, animated: true, completion:nil)
    }
    
    @IBAction func distanceAction(sender: UIButton) {
        delegate?.selectedMarker(marker!)
    }
}
