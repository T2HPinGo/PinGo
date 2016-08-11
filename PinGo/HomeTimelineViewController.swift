//
//  HomeTimelineViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/3/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class HomeTimelineViewController: BaseViewController {
    //MARK: - Outlets and variables
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var createNewTicketButton: UIButton!
    
    var selectedIndexPath: NSIndexPath?//(forRow: -1, inSection: 0)
    
        let colors = [UIColor(red: 123.0/255.0, green: 222.0/255.0, blue: 171.0/255.0, alpha: 1.0),
                    UIColor(red: 191.0/255.0, green: 136.0/255.0, blue: 217.0/255.0, alpha: 1.0),
                    UIColor(red: 162.0/255.0, green: 184.0/255.0, blue: 243.0/255.0, alpha: 1.0),
                    UIColor(red: 243.0/255.0, green: 190.0/255.0, blue: 118.0/255.0, alpha: 1.0),
                    UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 172.0/255.0, alpha: 1.0),
                    UIColor(red: 128.0/255.0, green: 237.0/255.0, blue: 239.0/255.0, alpha: 1.0),
                    UIColor(red: 182.0/255.0, green: 222.0/255.0, blue: 123.0/255.0, alpha: 1.0)]

    //MARK: - Fake Data
    let user = User(name: "Hien", id: "123456", location: nil, profileImagePath: nil)
    let worker = Worker(name: "Puppy", id: "qwerty", location: nil, profileImagePath: nil, currentLocation: nil, rating: 4.5)
    var ticket: Ticket!
    
    //MARK: - Load view
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
//        tableView.estimatedRowHeight = 150.0
//        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        //Fake data goes here
        ticket = Ticket(user: user, worker: worker, id: "1q2w3e4r", category: "Electricity" , title: "Broken Lightbulb", status: Status.Pending, issueImageVideoPath: nil, dateCreated: NSDate())
        tableView.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions


    
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
        return 7
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RequestStatusCell", forIndexPath: indexPath) as! RequestStatusCell
        cell.ticket = ticket
        cell.backgroundColor = colors[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        //if user tap on a cell, change the height
        return indexPath == selectedIndexPath ? RequestStatusCell.expandedHeight : RequestStatusCell.defaultHeight
    }
    
//    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        //
//        (cell as! RequestStatusCell).ignoreFrameChanges()
//    }
    
}

