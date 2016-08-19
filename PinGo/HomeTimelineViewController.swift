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
    
    var selectedIndexPath: NSIndexPath?//(forRow: -1, inSection: 0)
    
    var rating: String!
    
    var ticketList: [Ticket] = []

//    //MARK: - Fake Data
//    let user = User(name: "Hien", id: "123456", location: nil, profileImagePath: nil)
//    let worker = Worker(name: "Puppy", id: "qwerty", location: nil, profileImagePath: nil, currentLocation: nil, rating: 4.5)
    
    //MARK: - Load view
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        getTicketsOfUser()
        //Fake data goes here
//        ticket = Ticket(user: user, worker: worker, id: "1q2w3e4r", category: "Electricity" , title: "Broken Lightbulb", status: Status.Pending, issueImageVideoPath: nil, dateCreated: NSDate())
//        tableView.backgroundColor = UIColor.clearColor()
        
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
        if let workerBiddingCell = segue.sourceViewController as? WorkerDetailCell {
            
            if let newTicket = workerBiddingCell.ticket {
                ticketList.insert(newTicket, atIndex: 0)
                print(newTicket.category)
                tableView.reloadData()
            }
        }
    }

    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    //MARK: Helpers

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
        
        cell.backgroundColor = AppThemes.cellColors[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.backgroundColor = AppThemes.cellColors[indexPath.row] //set the tableview background to the same color of selected cell to get rid of that white back ground when the cell expands
        
        let previousIndexPath = selectedIndexPath
        
        //if the cell is already selected then set the selectedIndexPath to nil
        if indexPath == selectedIndexPath {
            selectedIndexPath = nil
        } else {
            //otherwise set it as indexPath
            selectedIndexPath = indexPath
        }
        
        var indexPathsToReload: [NSIndexPath] = []
        //if user previously selected a cell, add it to the indexPaths
        if let previous = previousIndexPath {
            indexPathsToReload.append(previous)
        }
        
        //if user select a new cell, add it to the indexPath
        if let current = selectedIndexPath {
            indexPathsToReload.append(current)
        }
        
        //expanding the cell that tapped and compressing the previous selected cell
        if indexPathsToReload.count > 0 {
            tableView.reloadRowsAtIndexPaths(indexPathsToReload, withRowAnimation: .Fade)
        }
    
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //
        (cell as! RequestStatusCell).watchFrameChanges()
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //
        (cell as! RequestStatusCell).removeFrameChanges()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        //if user tap on a cell, change the height
        return indexPath == selectedIndexPath ? RequestStatusCell.expandedHeight : RequestStatusCell.defaultHeight
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
            for JSONItem in JSONArrays {
                let ticket = Ticket(data: JSONItem)
                self.ticketList.append(ticket)
                self.tableView.reloadData()
            }
        }
    }
}



