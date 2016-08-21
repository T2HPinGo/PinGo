//
//  RequestStatusCell.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire
enum RequestHeight {
    case defaultHeight
    case expandedHeight
}

class RequestStatusCell: UITableViewCell {
    //MARK: - Outlets and Variables
    @IBOutlet weak var categoryIconContainerView: UIView!
    @IBOutlet weak var categoryIconImageView: UIImageView!
    
    @IBOutlet weak var connectionLineView: UIView!
    
    @IBOutlet weak var workerProfileImageView: UIImageView!
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var callWorkerView: UIView!
    
    @IBOutlet weak var ticketDetailView: UIView!
    @IBOutlet weak var requestTitleLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var ratingButton: UIButton!
    
    @IBOutlet weak var approveButton: UIButton!
//    var rating: String! {
//        didSet {
//            if rating != nil {
//                ratingButton.setImage(UIImage(named: rating), forState: .Normal)
//                ratingButton.tintColor = UIColor.whiteColor()
//                ratingButton.backgroundColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 25.0/255.0, alpha: 1.0)
//            } else {
//                ratingButton.setImage(UIImage(named: "rating"), forState: .Normal)
//                ratingButton.tintColor = UIColor.lightGrayColor()
//                ratingButton.backgroundColor = UIColor.clearColor()
//            }
//        }
//    }
    
    var themeColor: UIColor! {
        didSet {
            categoryIconContainerView.backgroundColor = themeColor
            ticketDetailView.backgroundColor = themeColor
            connectionLineView.backgroundColor = themeColor
            callWorkerView.backgroundColor = themeColor
        }
    }
    
    
    var ticket: Ticket! {
        didSet {
            workerNameLabel.text = ticket.worker?.username
            
            requestTitleLabel.text = ticket.title ?? ticket.category
            dateCreatedLabel.text = HandleUtil.changeUnixDateToNSDate(ticket.createdAt!)
            if ticket.status! == Status.Done {
                approveButton.setTitle(Status.Approved.rawValue, forState: .Normal)
            } else {
                 approveButton.setTitle(ticket.status?.rawValue, forState: .Normal)
            }
           
        }
    }
    
    ////MARK: - Load view
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAppearance()
        
        //add gesture
//        let callWorkerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showCollectionView(_:)))
//        chooseCategoryView.addGestureRecognizer(categoryViewGestureRecognizer)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - Helpers
    func setupAppearance(){
        
        //font
        requestTitleLabel.font = AppThemes.helveticaNeueRegular15
        dateCreatedLabel.font = AppThemes.helveticaNeueRegular14
        
        //allignment
        requestTitleLabel.textAlignment = .Left
        dateCreatedLabel.textAlignment = .Center
        
        //colors
        requestTitleLabel.textColor = UIColor.whiteColor()
        dateCreatedLabel.textColor = UIColor.whiteColor()
        
        //frames
        categoryIconContainerView.layer.cornerRadius = categoryIconContainerView.frame.width / 2
        workerProfileImageView.layer.cornerRadius = 5
        workerProfileImageView.layer.masksToBounds = true
        callWorkerView.layer.cornerRadius = 5
        
        //customize the separator
        //separatorInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0) //moves the separator lines between the cells a bit to the right so there are no lines between the thumbnail images
    }
    
    
    
    //MARK: - Actions
    @IBAction func onApprove(sender: UIButton) {
        // Change Status of the ticket to Approve
        let parameters: [String: AnyObject] = [
            "statusTicket": Status.Approved.rawValue,
            "idTicket": (ticket?.id!)!
        ]
        let url = "\(API_URL)\(PORT_API)/v1/updateStatusOfTicket"
        Alamofire.request(.POST, url, parameters: parameters).responseJSON { response  in
            print(response.result.value!)
            let JSON = response.result.value!["data"] as! [String: AnyObject]
            print(JSON)
            self.ticket = Ticket(data: JSON)
            SocketManager.sharedInstance.pushCategory(JSON)
        }
        
    }
    
    

}
