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
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var numbersOfTicketsPendingLabel: UILabel!
    
    @IBOutlet weak var ticketIconImageView: UIImageView!
    var selectedIndexPath: NSIndexPath?//(forRow: -1, inSection: 0)
    
    var rating: String!
    
    var ticketList: [Ticket] = []
    
    //MARK: - Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupAppearance()
        initSocketTicketOfUser()
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
        tableView.separatorStyle = .None
        
        //top and bottom panel
        bottomPanelView.layer.cornerRadius = 5
        bottomPanelView.backgroundColor = UIColor.whiteColor()//AppThemes.bottomPanelColor
        
        topPanelView.layer.cornerRadius = 5
        topPanelView.backgroundColor = UIColor.whiteColor()//AppThemes.topPannelColor
        
        //greeting label
        greetingLabel.font = AppThemes.avenirBlack21
        greetingLabel.textColor = AppThemes.textOnWhiteBackgroundColor
        let userFirstName = UserProfile.currentUser?.firstName ?? "User"
        print(UserProfile.currentUser?.firstName)

        greetingLabel.text = "Hello " + userFirstName
        
        //other Labels
        dateLabel.font = AppThemes.avenirBlack16
        dateLabel.textColor = AppThemes.textOnWhiteBackgroundColor
        
        notificationLabel.font = AppThemes.avenirBlack16
        notificationLabel.textColor = AppThemes.textOnWhiteBackgroundColor
        
        numbersOfTicketsPendingLabel.font = AppThemes.avenirBlack15
        
        //create ticket button
        createNewTicketButton.layer.cornerRadius = createNewTicketButton.frame.width / 2
        createNewTicketButton.layer.borderWidth = 1.5
        createNewTicketButton.layer.borderColor = AppThemes.buttonBorderColorOnWhiteBackgroundColor.CGColor
        createNewTicketButton.layer.backgroundColor = UIColor.whiteColor().CGColor
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
        
        let colorIndex = indexPath.row < AppThemes.cellColors.count ? indexPath.row : getCorrespnsingColorForCell(indexPath.row)
        cell.containerView.backgroundColor = AppThemes.cellColors[colorIndex]
        cell.backgroundColor = AppThemes.cellColors[colorIndex]
        
        
        //fake
        if rating != nil {
            cell.ratingButton.setImage(UIImage(named: rating), forState: .Normal)
        }
        
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
        }
    }
    func initSocketTicketOfUser(){
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



