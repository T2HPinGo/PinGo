//
//  WorkerHomeMapViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/31/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class WorkerHomeMapViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    var marker: GMSMarker?
    
    var tickets: [Ticket] = []
    
    var isShowingTableView = false //check if user list in table view is shown or not

    @IBOutlet weak var tableSlideUpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        //location = Location()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableViewHeightConstraint.constant = (view.frame.height - 69 - 49) / 2
        tableView.transform = CGAffineTransformMakeTranslation(0, tableViewHeightConstraint.constant) //add the start stage for table View
        tableSlideUpButton.transform = CGAffineTransformMakeTranslation(0, tableViewHeightConstraint.constant) ////add the start stage for tableViewSlideUpButton
        
        setupSubAppearance()
        initSocket()
    }
    
    //MARK: - Actions
    
    @IBAction func onTableSlideUp(sender: UIButton) {
        //if tableview is hidden, slide it up, if it is shown then slide it down
        if !isShowingTableView {
            UIView.animateKeyframesWithDuration(0.6, delay: 0, options: .CalculationModeCubic, animations: {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.33, animations: {
                    self.tableView.transform = CGAffineTransformIdentity
                    self.tableSlideUpButton.transform = CGAffineTransformIdentity
                })
                
                //fliping effect for tableSlideUpButton
                UIView.addKeyframeWithRelativeStartTime(0.33, relativeDuration: 0.63, animations: {
                    self.tableSlideUpButton.transform = CGAffineTransformMakeScale(1, 0.1)
                    self.tableSlideUpButton.setImage(UIImage(named: "down"), forState: .Normal)
                })
                
                UIView.addKeyframeWithRelativeStartTime(0.67, relativeDuration: 0.33, animations: {
                    self.tableSlideUpButton.transform = CGAffineTransformIdentity
                })
                }, completion: { finished in
                    self.isShowingTableView = !self.isShowingTableView
            })
        } else {
            UIView.animateKeyframesWithDuration(0.6, delay: 0, options: .CalculationModeCubic, animations: {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.33, animations: {
                    self.tableView.transform = CGAffineTransformMakeTranslation(0, self.tableViewHeightConstraint.constant)
                    self.tableSlideUpButton.transform = CGAffineTransformMakeTranslation(0, self.tableViewHeightConstraint.constant)
                })
                
                //fliping effect for tableSlideUpButton
                UIView.addKeyframeWithRelativeStartTime(0.33, relativeDuration: 0.63, animations: {
                    //self.tableSlideUpButton.transform = CGAffineTransformMakeScale(1, 0.1)
                    self.tableSlideUpButton.setImage(UIImage(named: "up"), forState: .Normal)
                })
                
                UIView.addKeyframeWithRelativeStartTime(0.67, relativeDuration: 0.33, animations: {
                    //self.tableSlideUpButton.transform = CGAffineTransformMakeScale(1, 1)
                })
                }, completion: { finished in
                    self.isShowingTableView = !self.isShowingTableView
            })
        }

    }
    
    
    // MARK: - Helpers
    func setupSubAppearance() {
        
    }
    
    func initSocket() {
        SocketManager.sharedInstance.getTicket { (ticket) in
            // Check category of ticket
            if ticket.category != Worker.currentUser?.category {
                return
            } else {
                var isNewTicket = true
                var index = 0
                if self.tickets.count > 0 {
                    for itemTicket in self.tickets {
                        
                        if itemTicket.id == ticket.id {
                            
                            if ticket.worker!.id != Worker.currentUser?.id && ticket.worker!.id != ""{
                                print("Not choose you")
                                //self.tickets.removeAtIndex(index)
                                //self.countPending -= 1
                                itemTicket.status = Status.ChoosenAnother
                                isNewTicket = false
                                break
                            } else {
                                if ticket.status == Status.Cancel{
                                    //self.tickets.removeAtIndex(index)
                                    //self.countPending -= 1
                                    itemTicket.status = ticket.status
                                    isNewTicket = false
                                    break
                                }  else {
                                    if ticket.status == Status.Approved {
                                        itemTicket.status = ticket.status
                                        //self.tickets.removeAtIndex(index)
                                        //self.countInserivce -= 1
                                        isNewTicket = false
                                        break
                                    } else {
                                        // Change Pending To Inservice
                                        itemTicket.status = ticket.status
                                        itemTicket.worker = ticket.worker
                                        isNewTicket = false
                                        
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
                }
                self.tableView.reloadData()
            }
            
        }
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
//MARK: - UITableViewDataSource, UITableViewDelegate
extension WorkerHomeMapViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5//workerList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkerDetailCell", forIndexPath: indexPath) as! WorkerDetailCell
        
//        cell.worker = workerList[indexPath.row]
//        cell.ticket = newTicket!
//        cell.mapViewController = self
        
        cell.workerNameLabel.text = "Puppy Ass"
        cell.workerRatingLabel.text = "4.5/5.0"
        cell.workerHourlyRateLabel.text = "$8000"
        return cell
    }
    
}




extension WorkerHomeMapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error location Manager")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        
        //center camera around
        let camera = GMSCameraPosition.cameraWithTarget(locations[0].coordinate, zoom: 14)
        self.mapView.camera = camera
        
        //add marker
        marker = GMSMarker(position: locations[0].coordinate)
        marker?.icon = UIImage(named: "marker")
        marker?.map = self.mapView
        
    }
}
