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

protocol RequestStatusCellDelegate{
    func requestStatusCellDelegate(homeTimeLineUser: HomeTimelineViewController,indexCell: NSIndexPath, statusTicket: Status)
}

class RequestStatusCell: UITableViewCell {
    //MARK: - Outlets and Variables
    //    @IBOutlet weak var categoryIconContainerView: UIView!
    //    @IBOutlet weak var categoryIconImageView: UIImageView!
    
    @IBOutlet weak var buttonAction: UIButton!
    
    //    @IBOutlet weak var connectionLineView: UIView!
    
    @IBOutlet weak var workerProfileImageView: UIImageView!
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var callWorkerView: UIView!
    
    @IBOutlet weak var ticketDetailView: UIView!
    @IBOutlet weak var requestTitleLabel: UILabel!
    
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var ticketImageView: UIImageView!
    
    @IBOutlet weak var approveButton: UIButton!
    
    @IBOutlet weak var labelMessage: UILabel!
    
    @IBOutlet weak var labelPrice: UILabel!
    
    @IBOutlet weak var labelDateBegin: UILabel!
    
    @IBOutlet weak var labelTimeBegin: UILabel!
    @IBOutlet weak var imageViewFinished: UIImageView!
    
    var homeTimeLineUser : HomeTimelineViewController?
    
    var delegate: RequestStatusCellDelegate?
    
    var indexPath: NSIndexPath?
    
    var themeColor: UIColor! {
        didSet {
            UIView.animateWithDuration(0.6) {
                // self.categoryIconContainerView.backgroundColor = self.themeColor
                self.ticketDetailView.backgroundColor = self.themeColor
                //                self.connectionLineView.backgroundColor = self.themeColor
                self.callWorkerView.backgroundColor = self.themeColor
            }
        }
    }
    
    var ticket: Ticket! {
        didSet {
            workerNameLabel.text = ticket.worker?.username
            imageViewFinished.hidden = true
            approveButton.hidden = false
            requestTitleLabel.text = ticket.title ?? ticket.category
            updateUIButtonByStatus((ticket.status?.rawValue)!)
            
            //load ticket image
            if ticket?.imageOne?.imageUrl! != "" {
                let imageUrl = ticket?.imageOne?.imageUrl!
                HandleUtil.loadImageViewWithUrl(imageUrl!, imageView: ticketImageView)
            } else {
                ticketImageView.image = UIImage(named: "no_image")
            }
            
            //worker profile image
            if ticket?.worker?.profileImage?.imageUrl! != "" {
                let imageUrl = ticket?.worker?.profileImage?.imageUrl!
                HandleUtil.loadImageViewWithUrl(imageUrl!, imageView: workerProfileImageView)
            } else {
                workerProfileImageView.image = UIImage(named: "profile_default")
            }
            // Set label message
            if ticket.status == Status.InService {
                labelMessage.text = "is working"
            } else {
                labelMessage.text = "has finished"
            }
            labelPrice.text = ticket.worker?.price
            labelDateBegin.text = ticket.dateBegin
            labelTimeBegin.text = ticket.timeBegin
        }
    }
    
    ////MARK: - Load view
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAppearance()
        
        //add gesture
        let callWorkerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(makePhoneCall(_:)))
        callWorkerView.addGestureRecognizer(callWorkerGestureRecognizer)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK: - Helpers
    func setupAppearance(){
        
        //font
        //        requestTitleLabel.font = AppThemes.helveticaNeueRegular15
        //        dateCreatedLabel.font = AppThemes.helveticaNeueRegular14
        
        //allignment
        //        requestTitleLabel.textAlignment = .Left
        //        dateCreatedLabel.textAlignment = .Center
        
        //colors
        //        requestTitleLabel.textColor = UIColor.whiteColor()
        //        dateCreatedLabel.textColor = UIColor.whiteColor()
        
        //frames
        //        categoryIconContainerView.layer.cornerRadius = categoryIconContainerView.frame.width / 2
        workerProfileImageView.layer.cornerRadius = 5
        workerProfileImageView.layer.masksToBounds = true
        callWorkerView.layer.cornerRadius = 5
        
        // button
        buttonAction.layer.cornerRadius = 5
        buttonAction.layer.borderColor = UIColor.whiteColor().CGColor
        buttonAction.layer.borderWidth = 1
    }
    
    
    
    //MARK: - Actions
    @IBAction func onApprove(sender: UIButton) {
        // Change Status of the ticket to Approve
        if approveButton.titleLabel?.text == Status.Approved.rawValue {
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
                self.updateUIWhenStatusIsApproved()
                self.delegate?.requestStatusCellDelegate(self.homeTimeLineUser!,indexCell: self.indexPath!, statusTicket: self.ticket.status!)
                SocketManager.sharedInstance.pushCategory(JSON)
            }
        }
        
    }
    
    func makePhoneCall(gestureRecognizer: UIGestureRecognizer) {
        if let phoneNumber = ticket.worker?.phoneNumber {
            let alert = UIAlertController(title: "", message: "Call " + phoneNumber, preferredStyle: .Alert)
            let callAction = UIAlertAction(title: "OK", style: .Default, handler: { _ in
                let url = NSURL(string: "tel://\(phoneNumber)")
                UIApplication.sharedApplication().openURL(url!)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alert.addAction(callAction)
            alert.addAction(cancelAction)
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    func updateUIWhenStatusIsApproved(){
        self.ratingButton.hidden = false
        //        self.themeColor = AppThemes.cellColors[2]
        self.imageViewFinished.hidden = false
        self.approveButton.hidden  = true
        
    }
    func updateUIButtonByStatus(status: String){
        switch status {
        case Status.Done.rawValue:
            approveButton.setTitle(Status.Approved.rawValue, forState: .Normal)
            break
        case Status.Approved.rawValue:
            updateUIWhenStatusIsApproved()
            break
        default:
            approveButton.setTitle(ticket.status?.rawValue, forState: .Normal)
            break
        }
    }
}