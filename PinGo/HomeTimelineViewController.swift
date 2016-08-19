//
//  HomeTimelineViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/3/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire
class HomeTimelineViewController: BaseViewController {
    //MARK: - Outlets and variables
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var createNewTicketButton: UIButton!
    
    @IBOutlet weak var bottomPanelView: UIView!
    
    @IBOutlet weak var topPanelView: UIView!
    
    var selectedIndexPath: NSIndexPath?//(forRow: -1, inSection: 0)
    
    var rating: String!
    
    var ticketList: [Ticket] = []
    
    //MARK: - Load view
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        setupAppearance()
    }
    
    override func viewDidAppear(animated: Bool) {
        //load ticket from server
        getTicketsOfUser()
    }
    
    //MARK: - Actions
    //this is the unwind segue from TicketRatingVC
    @IBAction func close(segue:UIStoryboardSegue) {
        if let ticketRatingViewController = segue.sourceViewController as? TicketRatingViewController {
            if let imageName = ticketRatingViewController.rating {
                rating = imageName
                print(rating)
                tableView.reloadData()
            }
        }
    }
    
    @IBAction func quitAfterPickWorker(segue: UIStoryboardSegue) {
//        if let workerBiddingCell = segue.sourceViewController as? WorkerDetailCell {
//            
//            if let newTicket = workerBiddingCell.ticket {
//                ticketList.insert(newTicket, atIndex: 0)
//                print(newTicket.category)
//                tableView.reloadData()
//            }
//        }
    }

    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    //MARK: Helpers
    func setupAppearance() {
        view.backgroundColor = AppThemes.backgroundColor
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorColor = AppThemes.backgroundColor
        tableView.separatorStyle = .SingleLineEtched
        
        //top and bottom panel
        //bottomPanelView.layer.cornerRadius = 5
        bottomPanelView.backgroundColor = AppThemes.bottomPanelColor
        
        
        //topPanelView.layer.cornerRadius = 5
        topPanelView.backgroundColor = AppThemes.topPannelColor
    }

}


//MARK: - EXTENSION UITableViewDataSource, UITableViewDelegate
extension HomeTimelineViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RequestStatusCell", forIndexPath: indexPath) as! RequestStatusCell
        cell.ticket = ticketList[indexPath.row]
        
        //fake
        if rating != nil {
            cell.ratingButton.setImage(UIImage(named: rating), forState: .Normal)
        }
        
        //cell.backgroundColor = AppThemes.cellColors[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        //Social sharing button
        let shareAction = UITableViewRowAction(style: .Default, title: "Share", handler: { (action, indexPath) -> Void in
            let defaultText = "Just checking in at "
            if let imageToShare = UIImage(named: "dog") {
                let activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
                self.presentViewController(activityController, animated: true, completion: nil)
            }
        })
        
        //Delete button
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) -> Void in
        })
        
        //customize background color for social action and delete action
        shareAction.backgroundColor = UIColor(red: 28.0/255.0, green: 165.0/255.0, blue: 253.0/255.0, alpha: 1)
        deleteAction.backgroundColor = UIColor(red: 202.0/255.0, green: 202.0/255.0, blue: 203.0/255.0, alpha: 1)
        
        return [deleteAction, shareAction]
    }
    
}

// MARK: Load data user tickets
extension HomeTimelineViewController {
    func getTicketsOfUser() {
        var parameters = [String : AnyObject]()
        parameters["statusTicket"] = "InService"
        parameters["idUser"] = UserProfile.currentUser?.id!
        Alamofire.request(.POST, "\(API_URL)\(PORT_API)/v1/userTickets", parameters: parameters).responseJSON { response  in
            print("HomeTineLineViewController ---")
            print("\(response.result.value)")
            let JSONArrays  = response.result.value!["data"] as! [[String: AnyObject]]
            if self.ticketList.count > 0 {
                self.ticketList.removeAll()
            }
            for JSONItem in JSONArrays {
                let ticket = Ticket(data: JSONItem)
                self.ticketList.append(ticket)
                self.tableView.reloadData()
            }
            
            //change status for ticket when worker has mark this ticket as "Done"
            SocketManager.sharedInstance.getTicketHasUpdateStatus({ (idTicket, statusTicket, idUser) in
                //if not current user than do nothing
                if idUser != UserProfile.currentUser!.id {
                    return
                }
                
                //if it is current user than update status ticket
                for ticket in self.ticketList {
                    if idTicket == ticket.id {
                        ticket.transferToEnum(from: statusTicket)
                    }
                }
                self.tableView.reloadData()
            })
        }
    }
}



