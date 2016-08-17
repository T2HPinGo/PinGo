//
//  TicketOfWorkerCell.swift
//  PinGo
//
//  Created by Cao Thắng on 8/15/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class TicketOfWorkerCell: UITableViewCell {

    @IBOutlet weak var titleTicketLabel: UILabel!
    
    @IBOutlet weak var categoryTicketLabel: UILabel!
    
    @IBOutlet weak var createByLabel: UILabel!
    
    @IBOutlet weak var imageProfileCreateBy: UIImageView!
    
    @IBOutlet weak var timeBegin: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    var ticket: Ticket? {
        didSet {
            titleTicketLabel.text = ticket?.title!
            categoryTicketLabel.text = ticket?.category!
            createByLabel.text = ticket?.user?.username!
            descriptionLabel.text = ""
            print("TicketOfWorkerCell: \((ticket?.status?.rawValue)!)" )
            statusLabel.text = ticket?.status?.rawValue
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func seeLocationAction(sender: AnyObject) {
    }
    
    @IBAction func pidAction(sender: AnyObject) {
        let jsonData = Worker.currentUser?.dataJson
        SocketManager.sharedInstance.applyTicket(jsonData!, ticketId: ticket!.title!, price: "150.000")
    }

    @IBAction func doneAction(sender: AnyObject) {
        
    }
}
