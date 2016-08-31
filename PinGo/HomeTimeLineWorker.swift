//
//  HomeTimeLineWorker.swift
//  PinGo
//
//  Created by Cao Thắng on 8/20/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import AFNetworking
import Alamofire
import CoreLocation

class HomeTimeLineWorker: UIViewController {
    
    
    @IBOutlet weak var viewAll: UIView!
    @IBOutlet weak var labelAll: UILabel!
    @IBOutlet weak var labelCountAll: UILabel!
    
    @IBOutlet weak var viewPending: UIView!
    @IBOutlet weak var labelCountPending: UILabel!
    @IBOutlet weak var labelPending: UILabel!
    
    
    @IBOutlet weak var viewInservice: UIView!
    @IBOutlet weak var labelInservice: UILabel!
    @IBOutlet weak var labelCountInservice: UILabel!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var labelMessageHello: UILabel!
    
    
    var tickets = [Ticket]()
    var ticketsFilter = [Ticket]()
    var countPending = 0
    var countInserivce = 0
    var indexButton = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        initViewAndActionForViewButtons()
        initTableView()
        loadDataFromAPI()
        initSocket()
        clearAllViewButtons()
        choosenViewButton(viewAll, labelTitle: labelAll)
        self.indexAtTab(indexButton)
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TicketDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let ticketDetailViewController = segue.destinationViewController as! TicketDetailViewController
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! WorkerTicketCell
                ticketDetailViewController.ticket = ticketsFilter[indexPath.row]
                ticketDetailViewController.colorTheme = cell.themeColor
                
            }
        }
        
    }
    
    
    @IBAction func onChanged(sender: AnyObject) {
        indexAtTab(segmentedControl.selectedSegmentIndex)
    }
    
    @IBAction func unwindFromSetprice(segue:UIStoryboardSegue) {
        //transfer data here
    }
    
}
extension HomeTimeLineWorker: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketsFilter.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkerTicketCell") as! WorkerTicketCell
        let ticket =  ticketsFilter[indexPath.row]
        cell.ticket = ticketsFilter[indexPath.row]
        
        //        let colorIndex = indexPath.row < AppThemes.cellColors.count ? indexPath.row : getCorrespnsingColorForCell(indexPath.row)
        cell.themeColor =  calculateColorThemeForCell(ticket.status!.rawValue)
        cell.homeTimeLineViewWorker = self
        return cell
    }
    func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 162
        tableView.rowHeight = UITableViewAutomaticDimension
    }
}
extension HomeTimeLineWorker {
    func loadDataFromAPI(){
        var parameters = [String : AnyObject]()
        parameters["status"] = "Pending"
        parameters["category"] = Worker.currentUser?.category
        parameters["idWorker"] = Worker.currentUser?.id
        Alamofire.request(.POST, "\(API_URL)\(PORT_API)/v1/ticketOnCategory", parameters: parameters).responseJSON { response  in
            print("ListTicketController ---")
            print("\(response.result.value)")
            let JSONArrays  = response.result.value!["data"] as! [[String: AnyObject]]
            for JSONItem in JSONArrays {
                let ticket = Ticket(data: JSONItem)
                if ticket.status != Status.Approved {
                    self.calculateCountForStatus((ticket.status?.rawValue)!)
                    self.tickets.append(ticket)
                }
                
            }
            self.indexAtTab(self.indexButton)
            self.tableView.reloadData()
            self.updateUIOfCountLabel()
        }
    }
    
    func initSocket() {
        SocketManager.sharedInstance.getTicket { (ticket) in
            // Check category of ticket
            if ticket.category != Worker.currentUser?.category {
                return
            } else {
                var isNewTicket :Bool = true
                var index = 0
                if self.tickets.count > 0 {
                    for itemTicket in self.tickets {
                        
                        if itemTicket.id == ticket.id {
                            
                            if ticket.worker!.id != Worker.currentUser?.id && ticket.worker!.id != ""{
                                //print("Not choose you")
//                                self.tickets.removeAtIndex(index)
//                                self.countPending -= 1
                                itemTicket.status = Status.ChoosenAnother
                                isNewTicket = false
                                break
                            } else {
                                if ticket.status == Status.Cancel{
//                                    self.tickets.removeAtIndex(index)
//                                    self.countPending -= 1
                                    itemTicket.status = ticket.status
                                    isNewTicket = false
                                    break
                                }  else {
                                    if ticket.status == Status.Approved {
                                        itemTicket.status = ticket.status
//                                        self.tickets.removeAtIndex(index)
//                                        self.countInserivce -= 1
                                        isNewTicket = false
                                        break
                                    } else {
                                        // Change Pending To Inservice
                                        itemTicket.status = ticket.status
                                        itemTicket.worker = ticket.worker
                                        isNewTicket = false
                                        self.countInserivce += 1
                                        self.countPending -= 1
                                        
                                        break
                                    }
                                    // Change status Pending to Inservice
                                                                  }
                            }
                            // Remove ticket to history if ticket has been approved by user
                           
                            
                        }
                        index += 1
                    }
                }
                if isNewTicket {
                    self.tickets.insert(ticket, atIndex: 0)
                    self.countPending += 1
                }
                self.indexAtTab(self.indexButton)
                self.tableView.reloadData()
                self.updateUIOfCountLabel()
            }
            
        }
    }
}
extension HomeTimeLineWorker {
    //filter tickets based on their status
    func filterTicketList(status: String) {
        if ticketsFilter.count > 0 {
            ticketsFilter.removeAll()
        }
        for ticket in tickets {
            if ticket.status?.rawValue == status {
                ticketsFilter.append(ticket)
            }
        }
    }
    
    //
    func filterTicketListForInserviceAndDone(){
        if ticketsFilter.count > 0 {
            ticketsFilter.removeAll()
        }
        for ticket in tickets {
            if ticket.status == Status.InService || ticket.status == Status.Done || ticket.status == Status.Approved{
                ticketsFilter.append(ticket)
            }
        }
    }
    
    func indexAtTab(index: Int){
        switch index {
        case 0:
            //all tickets
            ticketsFilter = tickets
            break
        case 1:
            //ticket pending
            filterTicketList(Status.Pending.rawValue)
            break
        case 2:
            //ticket inservice and done
            filterTicketListForInserviceAndDone()
            break
        default:
            break
        }
        tableView.reloadData()
    }
}
extension HomeTimeLineWorker {
    func viewAllAction(sender: AnyObject){
        clearAllViewButtons()
        choosenViewButton(viewAll, labelTitle: labelAll)
        indexButton = 0
        self.indexAtTab(indexButton)
        
    }
    
    func viewPendingAction(sender: AnyObject){
        clearAllViewButtons()
        choosenViewButton(viewPending, labelTitle: labelPending)
        indexButton = 1
        self.indexAtTab(indexButton)
    }
    
    func viewInserviceAction(sender: AnyObject){
        clearAllViewButtons()
        choosenViewButton(viewInservice, labelTitle: labelInservice)
        indexButton = 2
        self.indexAtTab(indexButton)
    }
    func initViewAndActionForViewButtons (){
        labelMessageHello.text = "Hello \((Worker.currentUser?.getFullName())!) !"
        
        clearAllViewButtons() //change the background colors of allView, pendingView, inServiceView to clear, and their label text to white
        
        //View All
        viewAll.layer.borderColor = UIColor.whiteColor().CGColor
        viewAll.layer.borderWidth = 1
        
        let gestureAll = UITapGestureRecognizer(target: self, action: #selector(HomeTimeLineWorker.viewAllAction(_:)))
        viewAll.addGestureRecognizer(gestureAll)
        labelCountAll.textColor = AppThemes.cellColors[0]
        
        // View Pending
        viewPending.layer.borderColor = UIColor.whiteColor().CGColor
        viewPending.layer.borderWidth = 1
        
        let gesturePending = UITapGestureRecognizer(target: self, action: #selector(HomeTimeLineWorker.viewPendingAction(_:)))
        viewPending.addGestureRecognizer(gesturePending)
        labelCountPending.textColor =  AppThemes.cellColors[1]
        // View Inservice
        viewInservice.layer.borderColor = UIColor.whiteColor().CGColor
        viewInservice.layer.borderWidth = 1
        
        let getstureInservice = UITapGestureRecognizer(target: self, action: #selector(HomeTimeLineWorker.viewInserviceAction(_:)))
        viewInservice.addGestureRecognizer(getstureInservice)
        labelCountInservice.textColor =  AppThemes.cellColors[2]
    }
}
// MARK: ViewButtons
extension HomeTimeLineWorker {
    
    func clearAllViewButtons(){
        clearViewButton(viewAll, labelTitle: labelAll)
        clearViewButton(viewInservice, labelTitle: labelInservice)
        clearViewButton(viewPending, labelTitle: labelPending)
    }
    func clearViewButton(view: UIView, labelTitle: UILabel) {
        view.backgroundColor = UIColor.clearColor()
        labelTitle.textColor = UIColor.whiteColor()
    }
    func choosenViewButton(view: UIView, labelTitle: UILabel){
        view.backgroundColor = UIColor.whiteColor()
        labelTitle.textColor = AppThemes.appColorTheme
    }
}
// MARK : Logic Count Button
extension HomeTimeLineWorker {
    func calculateColorThemeForCell(status : String) -> UIColor{
        switch status {
        case Status.Pending.rawValue:
            return AppThemes.cellColors[0]
        case Status.InService.rawValue:
            return AppThemes.cellColors[1]
        case Status.Done.rawValue:
            return AppThemes.cellColors[1]
        default:
            return AppThemes.cellColors[2]
        }
    }
    func calculateCountForStatus(status: String){
        switch status {
        case Status.Pending.rawValue:
            countPending += 1
            return
        case Status.InService.rawValue:
            countInserivce += 1
            return
        case Status.Done.rawValue:
            countInserivce += 1
            return
        default:
            print("Inservice")
        }
    }
    func updateUIOfCountLabel() {
        labelCountAll.text = "\(ticketsFilter.count)"
        labelCountInservice.text = "\(countInserivce)"
        labelCountPending.text = "\(countPending)"
    }
}