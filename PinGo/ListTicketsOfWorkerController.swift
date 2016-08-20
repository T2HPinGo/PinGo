//
//  ListTicketsOfWorkerController.swift
//  PinGo
//
//  Created by Cao Thắng on 8/15/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire
class ListTicketsOfWorkerController: UIViewController {
    
    var tickets = [Ticket]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initCollectionView()
        loadDataFromAPI()
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

// MARK: - CollectionView
extension ListTicketsOfWorkerController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return  1 //row number
    }
    
    func initCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tickets.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TicketOfWorkerCell", forIndexPath: indexPath) as! TicketOfWorkerCell
        cell.ticket = tickets[indexPath.row]
        return cell
    }
}

// MARK: - InitSocket
extension ListTicketsOfWorkerController {
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
                    self.collectionView.reloadData()
                }
             
            }
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
                                // Change status Pending to Inservice
                                itemTicket.status = ticket.status
                                isNewTicket = false
                                break
                            }
                            
                        }
                        index += 1
                    }
                }
                if isNewTicket {
                    self.tickets.append(ticket)
                }
                self.collectionView.reloadData()
            }
            
        }
        
    }
}