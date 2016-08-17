//
//  ListTicketsOfWorkerController.swift
//  PinGo
//
//  Created by Cao Thắng on 8/15/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class ListTicketsOfWorkerController: UIViewController {
    
    var tickets = [Ticket]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initTableView()
        initSocket()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - TableView
extension ListTicketsOfWorkerController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TicketOfWorkerCell") as! TicketOfWorkerCell
        cell.ticket = tickets[indexPath.row]
        return cell
    }
    
    func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}
// MARK: - InitSocket
extension ListTicketsOfWorkerController {
    func initSocket() {
        SocketManager.sharedInstance.getTicket { (ticket) in
            // Check category of ticket
            if ticket.category != Worker.currentUser?.category {
                return
            } else {
                var isNewTicket :Bool = true
                if self.tickets.count > 0 {
                    for itemTicket in self.tickets {
                        if itemTicket.id == ticket.id {
                            itemTicket.status = ticket.status
                            isNewTicket = false
                            break
                        }
                    }
                }
                if isNewTicket {
                    self.tickets.append(ticket)
                }
                self.tableView.reloadData()
            }
            
        }
        
    }
}