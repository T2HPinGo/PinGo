//
//  TicketBiddingViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/9/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class TicketBiddingViewController: UIViewController {
    @IBOutlet weak var ticketDetailView: UIView!
    @IBOutlet weak var ticketTitleLabel: UILabel!
    @IBOutlet weak var ticketPaymentLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!
    
    var activityIndicatorView: NVActivityIndicatorView! = nil
    
    var newTicket: Ticket!
    
    var workerList: [Worker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        let cellNib = UINib(nibName: "NoResultFound", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "NoResultFound")
        
        //set up loading indicator
        let width: CGFloat = 30
        let height: CGFloat = 30
        let x  = ticketDetailView.frame.width / 2 - width/2
        let y = ticketDetailView.frame.height / 2 - height/2
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        setupIndicator(withFrame: frame)
        let resetButton = UIButton(frame: frame)
        resetButton.setImage(UIImage(named: "greentech"), forState: .Normal)
        
        resetButton.addTarget(self, action: #selector(buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        ticketDetailView.addSubview(resetButton)
        activityIndicatorView.startAnimation()
        
        //set up appearance (need to refactor)
        ticketTitleLabel.text = newTicket.title
        
        
        //load worker list
        SocketManager.sharedInstance.getWorkers { (worker, idTicket) in
            if self.newTicket.id != idTicket {
                return
            }
            self.workerList.append(worker)
            self.tableView.reloadData()
        }
    }
    
    

    /*
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    */
    
    @IBAction func filterTapped(sender: UIBarButtonItem) {
    }

    @IBAction func cancelTicketTapped(sender: UIButton) {
    }
    
    //MARK: - Helpers
    func setupIndicator(withFrame frame: CGRect) {
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallScaleMultiple, color: UIColor.lightGrayColor(), padding: 70)
        ticketDetailView.addSubview(activityIndicatorView)
    }    
    
    func buttonTapped(sender: UIButton) {
        if activityIndicatorView.animating {
            activityIndicatorView.stopAnimation()
        } else {
            activityIndicatorView.startAnimation()
        }
    }
    
    //MARK: - Actions
    @IBAction func cancelTapped(sender: UIButton) {
        let alert = UIAlertController(title: "Cancel Request", message: "This process can no be undone. Are you sure? Tap OK to cancel this request", preferredStyle: .Alert)
        let okACtion = UIAlertAction(title: "OK", style: .Default) { _ in
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(okACtion)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
}



// MARK: - TableView data source and delegate
extension TicketBiddingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workerList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkerHistoryCell", forIndexPath: indexPath) as! WorkerDetailCell
        
        let colorIndex = indexPath.row < AppThemes.cellColors.count ? indexPath.row : getCorrespnsingColorForCell(indexPath.row)
        cell.backgroundColor = AppThemes.cellColors[colorIndex]
        cell.worker = workerList[indexPath.row]
        cell.ticket = newTicket!
        return cell
    }
    
}
