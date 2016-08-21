//
//  WorkerTicketCell.swift
//  PinGo
//
//  Created by Cao Thắng on 8/20/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire
class WorkerTicketCell: UITableViewCell {
    
    // View Status

    @IBOutlet weak var viewWordOfStatus: UIView!
    
    @IBOutlet weak var labelStatus: UILabel!
    // View User
    @IBOutlet weak var imageViewProfile: UIImageView!
    
    @IBOutlet weak var labelUsername: UILabel!
    
    @IBOutlet weak var ticketDetailView: UIView!

    @IBOutlet weak var connectionLineView: UIView!
    
    // View Info
    @IBOutlet weak var imageViewTicket: UIImageView!
    
    @IBOutlet weak var labelPhoneNumber: UILabel!

    
    @IBOutlet weak var imageViewLocation: UIImageView!
    
    @IBOutlet weak var buttonCall: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var labelDateCreated: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    var themeColor: UIColor! {
        didSet {
            ticketDetailView.backgroundColor = themeColor
            viewWordOfStatus.backgroundColor = themeColor
            connectionLineView.backgroundColor = themeColor
        }
    }
    
    // Ticket
    var ticket: Ticket? {
        didSet {
            // View Status
            let oneWord = HandleUtil.getOneWordOfStatus((ticket?.status?.rawValue)!)
            labelStatus.text = oneWord
            viewWordOfStatus.layer.cornerRadius = viewWordOfStatus.frame.size.width / 2
            viewWordOfStatus.layer.masksToBounds = true
            // View User
            if ticket?.user?.profileImage?.imageUrl! != "" {
                let profileUser = ticket?.user?.profileImage?.imageUrl!
                HandleUtil.loadImageViewWithUrl(profileUser!, imageView: imageViewProfile)
                imageViewProfile.layer.cornerRadius = 5
                imageViewProfile.clipsToBounds = true
            }
            labelUsername.text = ticket?.user?.getFullName()
            // Check block or un block phoneNumber and Address
            if ticket?.worker?.id == Worker.currentUser?.id {
                // address
                labelPhoneNumber.text = ticket?.user?.phoneNumber
                // Location
                if ticket?.location?.address != "" {
                    //labelLocation.text = ticket?.location?.address!
                } else {
                    //labelLocation.text = "No Address"
                }

            } else {
                labelPhoneNumber.text = "Blocked"
                //labelLocation.text = "Blocked"
                
            }
    
            // View Information
//            buttonCall.layer.cornerRadius = buttonCall.frame.size.width / 2
//            buttonCall.layer.masksToBounds = true
//            buttonCall.layer.borderColor = UIColor.whiteColor().CGColor
//            buttonCall.layer.borderWidth = 2
            if ticket?.imageOne?.imageUrl! != "" {
                let imageTicket = ticket?.imageOne?.imageUrl!
                HandleUtil.loadImageViewWithUrl(imageTicket!, imageView: imageViewTicket)
            } else {
                imageViewTicket.image = UIImage(named: "no_image")
            }
           
            
            labelTitle.text = ticket?.title!
            labelDateCreated.text = HandleUtil.changeUnixDateToNSDate(ticket!.createdAt!)
            actionButton.layer.cornerRadius = 5
            actionButton.layer.borderColor = UIColor.whiteColor().CGColor
            actionButton.layer.borderWidth = 1
        
            if ticket?.status == Status.InService {
                actionButton.setTitle("Done", forState: .Normal)
            } else {
                if ticket?.status == Status.Pending{
                    actionButton.setTitle("Bid", forState: .Normal)
                } else {
                    if ticket?.status == Status.Done {
                        actionButton.setTitle("Waiting ...", forState: .Normal)
                    }
                }
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func onDoAction(sender: UIButton) {
        if ticket?.status?.rawValue == "Pending" {
            if actionButton.titleLabel!.text != "Waiting" {
                
//                let jsonData = Worker.currentUser?.dataJson
//                SocketManager.sharedInstance.applyTicket(jsonData!, ticketId: ticket!.id!, price: "150.000")
//                actionButton.setTitle("Waiting", forState: .Normal)
            }
        } else {
            let parameters: [String: AnyObject] = [
                "statusTicket": Status.Done.rawValue,
                "idTicket": (ticket?.id!)!
            ]
            let url = "\(API_URL)\(PORT_API)/v1/updateStatusOfTicket"
            Alamofire.request(.POST, url, parameters: parameters).responseJSON { response  in
                print(response.result.value!)
                let JSON = response.result.value!["data"] as! [String: AnyObject]
                print(JSON)
                self.ticket = Ticket(data: JSON)
                SocketManager.sharedInstance.updateTicket(self.ticket!.id!, statusTicket: (self.ticket?.status?.rawValue)!, idUser: (self.ticket?.user?.id)!)
            }
        }
    }
    
}
