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
    
    var ticket: Ticket? {
        didSet {
            titleTicketLabel.text = ticket?.title!
            categoryTicketLabel.text = ticket?.category!
            createByLabel.text = ticket?.user?.username!
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
    
    @IBAction func pidAction(sender: AnyObject) {
        let jsonData = Worker.currentUser?.dataJson
        SocketManager.sharedInstance.applyTicket(jsonData!, ticketId: ticket!.title!, price: "150.000")
    }

}
