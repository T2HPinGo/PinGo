//
//  TicketWorkerCell.swift
//  PinGo
//
//  Created by Cao Thắng on 9/2/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire
class TicketWorkerCell: UITableViewCell {
    
    
    // Init UI View
    @IBOutlet weak var imageViewTicket: UIImageView!
    
    @IBOutlet weak var buttonAction: UIButton!
    
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var labelMessage: UILabel!
    
    @IBOutlet weak var labelWorker: UILabel!
    
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var imageViewWorker: UIImageView!
    
    @IBOutlet weak var labelDate: UILabel!
    
    var location: CLLocation?
    
    var workerHomeMapViewController: WorkerHomeMapViewController?
    
    var ticket: Ticket? {
        didSet {
            labelTitle.text = ticket?.title
            labelWorker.text = ticket?.user?.firstName
            
            if ticket?.worker?.price != "" {
                labelPrice.text = ticket?.worker?.price
            } else {
                labelPrice.text = "None price"
            }
            // Load profile worker
            if ticket?.user?.profileImage?.imageUrl! != "" {
                let profileUser = ticket?.user?.profileImage?.imageUrl!
                HandleUtil.loadImageViewWithUrl(profileUser!, imageView: imageViewWorker)
                imageViewWorker.layer.cornerRadius = 5
                imageViewWorker.clipsToBounds = true
            } else {
                imageViewWorker.image = UIImage(named: "profile_default")
            }
            // Load ticket image
            if ticket?.imageOne?.imageUrl! != "" {
                let imageTicket = ticket?.imageOne?.imageUrl!
                HandleUtil.loadImageViewWithUrl(imageTicket!, imageView: imageViewTicket)
                imageViewTicket.layer.cornerRadius = 5
                imageViewTicket.clipsToBounds = true
            } else {
                imageViewTicket.image = UIImage(named: "no_image")
            }
            // Update ticket with status 
            if ticket?.status == Status.InService {
                buttonAction.setTitle("Done", forState: .Normal)
                self.labelMessage.text = "wait for you"
            } else {
                if ticket?.status == Status.Pending{
                    buttonAction.setTitle("Bid", forState: .Normal)
                    self.labelMessage.text = "create new ticket"
                } else {
                    if ticket?.status == Status.Done {
                        buttonAction.setTitle("Waiting ...", forState: .Normal)
                    } else {
                        if ticket?.status == Status.Approved {
                            self.labelMessage.text = "has approved"
                            self.buttonAction.hidden = true
                           // self.imageFinish.hidden = false
                        } else {
                            if ticket?.status == Status.Cancel {
                                //self.themeColor = UIColor.redColor()
                                self.labelMessage.text = "cancel ticket"
                            } else {
                                if ticket?.status == Status.ChoosenAnother {
                                   // self.themeColor = UIColor.redColor()
                                    self.labelMessage.text = "choose another worker"
                                }
                            }
                        }
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
    
    @IBAction func onDoAction(sender: AnyObject) {
        if ticket?.status?.rawValue == "Pending" {
            
            if buttonAction.titleLabel!.text != "Waiting" {
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Worker", bundle: nil)
                
                let resultViewController =
                    storyBoard.instantiateViewControllerWithIdentifier("SetPricePopUpViewController") as! SetPricePopUpViewController
                resultViewController.ticket = self.ticket!
                resultViewController.location = self.location
                workerHomeMapViewController!.presentViewController(resultViewController, animated: true, completion:nil)
                buttonAction.setTitle("Waiting", forState: .Normal)
                
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
