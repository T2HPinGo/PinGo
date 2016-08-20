//
//  TicketOfWorkerCell.swift
//  PinGo
//
//  Created by Cao Thắng on 8/19/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import AFNetworking
import Alamofire
class TicketOfWorkerCell: UICollectionViewCell {
    
    @IBOutlet weak var profileUserImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
  
    @IBOutlet weak var statusButton: UIButton!
    
    @IBOutlet weak var dateStartOfTicket: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
  
    @IBOutlet weak var phoneButton: UIButton!
    
    @IBOutlet weak var imageViewOfTicket: UIImageView!
    
    
    @IBOutlet weak var categoryImageView: UIImageView!
    
    @IBOutlet weak var titleTicketLabel: UILabel!
    
    

    
    @IBOutlet weak var priceTicketLabel: UILabel!
    

    
    
    var ticket: Ticket? {
        didSet {
            let profileUser = ticket?.user?.profileImage?.imageUrl!
            if let profileUser = profileUser {
                loadImageViewWithUrl(profileUser, imageView: profileUserImageView)
            }
            usernameLabel.text = ticket?.user?.username!
            phoneButton.setTitle(ticket?.user?.phoneNumber!, forState: .Normal)
            let unixDate = ticket?.createdAt!
            if let number = Int(unixDate!) {
                let myNumber = NSNumber(integer:number)
                let epocTime = NSTimeInterval(myNumber) / 1000
                let myDate = NSDate(timeIntervalSince1970:  epocTime)
                dateStartOfTicket.text = "\(myDate)"
            } else {
                print("'\(unixDate)' did not convert to an Int")
            }
            statusButton.setTitle(ticket?.status!.rawValue, forState: .Normal)
            statusButton.layer.cornerRadius = 5
            statusButton.clipsToBounds = true
            statusButton.layer.borderColor = UIColor.cyanColor().CGColor
            statusButton.layer.borderWidth = 1
            titleTicketLabel.text = ticket?.title!
            let imageTicket = ticket?.imageOne?.imageUrl!
            if let imageTicket = imageTicket {
                loadImageViewWithUrl(imageTicket, imageView: imageViewOfTicket)
                
            }
            if ticket?.status == Status.InService {
                actionButton.setTitle("Done", forState: .Normal)
            } else {
                if ticket?.status == Status.Pending{
                    actionButton.setTitle("Bid", forState: .Normal)

                }
            }
           
        }
    }
    
    func loadImageViewWithUrl(sourceImage: String, imageView: UIImageView){
        
        let stringUrl = "\(API_URL)\(PORT_API)/v1\(sourceImage)"
        print("URl: \(stringUrl)")
        let url = NSURL(string: stringUrl)
        //imageView.setImageWithURL(url!)
        let imageRequest = NSURLRequest(URL: url!)
        
        imageView.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    imageView.alpha = 0.0
                    imageView.image = image
                    UIView.animateWithDuration(0.7, animations: { () -> Void in
                        imageView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    imageView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
    }

    @IBAction func pidAction(sender: UIButton) {
       
        if ticket?.status?.rawValue == "Pending" {
            if actionButton.titleLabel!.text != "Waiting" {
                let jsonData = Worker.currentUser?.dataJson
                SocketManager.sharedInstance.applyTicket(jsonData!, ticketId: ticket!.title!, price: "150.000")
                actionButton.setTitle("Waiting", forState: .Normal)
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
