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
    
    @IBOutlet weak var greetingLabel: UILabel!
    
    @IBOutlet weak var buttonLogout: UIButton!

    // New Views 
    
    @IBOutlet weak var ImageViewProfile: UIImageView!
    
    @IBOutlet weak var labelUserName: UILabel!
    
    @IBOutlet weak var viewInservice: UIView!
    
    
    @IBOutlet weak var viewHistory: UIView!
    @IBOutlet weak var labelCountInservice: UILabel!
    
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var labelCountHistory: UILabel!
    
    @IBOutlet weak var labelInservice: UILabel!
    
    
    @IBOutlet weak var labelHistory: UILabel!
    
    // -----
    var selectedIndexPath: NSIndexPath?//(forRow: -1, inSection: 0)
    
    var rating: String!
    
    var ticketList: [Ticket] = []
    
    //MARK: - Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewActionOfButton()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
        
        initSocketTicketOfUser()
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
    
    @IBAction func logOutAction(sender: AnyObject) {
        UserProfile.currentUser = nil
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.logout()
    }
    
    @IBAction func onRatingAction(sender: UIButton) {

    }
    
    @IBAction func quitAfterPickWorker(segue: UIStoryboardSegue) {
    }
    
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ratingSegue" {
            if let choosenCell = sender!.superview!!.superview!.superview as? RequestStatusCell{
                let ticketRatingController = segue.destinationViewController as! TicketRatingViewController
                ticketRatingController.nameWorker = (choosenCell.ticket.worker?.getFullName())!
                ticketRatingController.idTicket = (choosenCell.ticket.id)!
            }

        }
    }
    
    
    //MARK: Helpers
    func setupAppearance() {
        tableView.separatorStyle = .None
        
        
        //create ticket button
        labelUserName.text = "\((UserProfile.currentUser?.getFullName())!)"
        if UserProfile.currentUser?.profileImage?.imageUrl! != "" {
            let profileUser = UserProfile.currentUser?.profileImage?.imageUrl!
            HandleUtil.loadImageViewWithUrl(profileUser!, imageView: ImageViewProfile)
            ImageViewProfile.layer.cornerRadius = ImageViewProfile.frame.width / 2
            ImageViewProfile.clipsToBounds = true
            ImageViewProfile.layer.borderColor = UIColor.whiteColor().CGColor
            ImageViewProfile.layer.borderWidth = 1
        }else {
            ImageViewProfile.image = UIImage(named: "profile_default")
        }
        
        createNewTicketButton.layer.cornerRadius = createNewTicketButton.frame.size.width / 2
        createNewTicketButton.layer.masksToBounds = true
        createNewTicketButton.layer.borderColor = UIColor.whiteColor().CGColor
        createNewTicketButton.layer.borderWidth = 1
        
        buttonEdit.layer.cornerRadius = buttonEdit.frame.size.width / 2
        buttonEdit.layer.masksToBounds = true
        buttonEdit.layer.borderColor = UIColor.whiteColor().CGColor
        buttonEdit.layer.borderWidth = 1
        
        
        buttonLogout.layer.cornerRadius = buttonLogout.frame.size.width / 2
        buttonLogout.layer.masksToBounds = true
        buttonLogout.layer.borderColor = UIColor.whiteColor().CGColor
        buttonLogout.layer.borderWidth = 1
        
        labelEmail.text = UserProfile.currentUser?.email!
        initOpacityBarView()
       
    }
    func initOpacityBarView(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }
    
}


//MARK: - EXTENSION UITableViewDataSource, UITableViewDelegate
extension HomeTimelineViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RequestStatusCell", forIndexPath: indexPath) as! RequestStatusCell
        let ticket = ticketList[indexPath.row]
         cell.ticket = ticket
        
        if ticket.status == Status.InService {
            //cell.themeColor = AppThemes.cellColors[0]
            cell.ratingButton.hidden = true
            
        } else {
            cell.themeColor = AppThemes.cellColors[1]
        }
        
        //fake
        if rating != nil {
            cell.ratingButton.setImage(UIImage(named: rating), forState: .Normal)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
            
            if response.response != nil{
                
                let JSONArrays  = response.result.value!["data"] as! [[String: AnyObject]] //{
                if self.ticketList.count > 0 {
                    self.ticketList.removeAll()
                }
                for JSONItem in JSONArrays {
                    let ticket = Ticket(data: JSONItem)
                    if ticket.status != Status.Pending{
                        self.ticketList.append(ticket)
                    }
                }
                self.tableView.reloadData()
               // self.countLabelTickets.text = "\(self.ticketList.count)"
            }
        }
//        else {
//                let alert = UIAlertController(title: "Network Error", message: "Cannot load data due to no internet connection. Please check your connection", preferredStyle: .Alert)
//                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
//                alert.addAction(okAction)
//                self.presentViewController(alert, animated: true, completion: nil)
//            }
//        }
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

extension HomeTimelineViewController {
    func initViewActionOfButton(){
        
        let gestureInservice = UITapGestureRecognizer(target: self, action: #selector(HomeTimelineViewController.viewInserviceAction(_:)))
        viewInservice.addGestureRecognizer(gestureInservice)
        
        let gestureHistory = UITapGestureRecognizer(target: self, action: #selector(HomeTimelineViewController.viewHistoryAction(_:)))
        viewHistory.addGestureRecognizer(gestureHistory)
    }
    
    func viewInserviceAction(sender: AnyObject){
        clearAllViewButtons()
        choosenViewButton(viewInservice, labelTitle: labelCountInservice)
        
    }
    
    func viewHistoryAction(sender: AnyObject){
        clearAllViewButtons()
        choosenViewButton(viewHistory, labelTitle: labelCountHistory)
    }
    
    func clearAllViewButtons(){
        clearViewButton(viewInservice, labelTitle: labelCountInservice)
        clearViewButton(viewHistory, labelTitle: labelCountHistory)
    }
    func clearViewButton(view: UIView, labelTitle: UILabel) {
        view.backgroundColor = UIColor.clearColor()
        labelTitle.textColor = UIColor.redColor()
    }
    func choosenViewButton(view: UIView, labelTitle: UILabel){
        view.backgroundColor = AppThemes.redSpeacialColor
        labelTitle.textColor = UIColor.whiteColor()
    }
}
// MARK: Filer list
extension HomeTimelineViewController {
    
}



