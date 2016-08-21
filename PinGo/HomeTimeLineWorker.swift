//
//  HomeTimeLineWorker.swift
//  PinGo
//
//  Created by Cao Thắng on 8/20/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire
class HomeTimeLineWorker: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var tickets = [Ticket]()
    var ticketsFilter = [Ticket]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initTableView()
        loadDataFromAPI()
        initSocket()
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
                ticketDetailViewController.ticket = ticketsFilter[indexPath.row]
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
        cell.ticket = ticketsFilter[indexPath.row]
        
        let colorIndex = indexPath.row < AppThemes.cellColors.count ? indexPath.row : getCorrespnsingColorForCell(indexPath.row)
        cell.themeColor = AppThemes.cellColors[colorIndex]
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
                    self.tickets.append(ticket)
                    
                }
                
            }
            self.indexAtTab(self.segmentedControl.selectedSegmentIndex)
            self.tableView.reloadData()
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
                            // Remove ticket to history if ticket has been approved by user
                            if ticket.status == Status.Approved {
                                self.tickets.removeAtIndex(index)
                                isNewTicket = false
                                break
                            } else {
                                
                                if ticket.worker!.id != Worker.currentUser?.id {
                                    print("Not choose you")
                                    break
                                } else { // Change status Pending to Inservice
                                    itemTicket.status = ticket.status
                                    itemTicket.worker = ticket.worker
                                    isNewTicket = false
                                    break
                                }
                                
                            }
                            
                        }
                        index += 1
                    }
                }
                if isNewTicket {
                    self.tickets.insert(ticket, atIndex: 0)
//                    self.tickets.append(ticket)
                }
                self.indexAtTab(self.segmentedControl.selectedSegmentIndex)
                self.tableView.reloadData()
            }
            
        }
        
    }
}
extension HomeTimeLineWorker {
    func filterTicketList(status: String){
        if ticketsFilter.count > 0 {
            ticketsFilter.removeAll()
        }
        for ticket in tickets {
            if ticket.status?.rawValue == status {
                ticketsFilter.append(ticket)
            }
        }
    }
    func indexAtTab(index: Int){
        switch index
        {
        case 0:
            ticketsFilter = tickets
            break
        case 1:
            filterTicketList(Status.Pending.rawValue)
            break
        case 2:
            filterTicketList(Status.InService.rawValue)
            break
        case 3:
            filterTicketList(Status.Done.rawValue)
            break
        default:
            break;
        }
        tableView.reloadData()
    }
}
