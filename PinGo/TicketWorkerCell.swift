//
//  TicketWorkerCell.swift
//  PinGo
//
//  Created by Cao Thắng on 9/2/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class TicketWorkerCell: UITableViewCell {

    
    // Init UI View
    @IBOutlet weak var imageViewTicket: UIImageView!
    
    @IBOutlet weak var buttonAction: UIButton!
    
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var labelMessage: UILabel!
    
    @IBOutlet weak var labelWorker: UILabel!
    
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var imageViewWorker: UIImageView!
    
    @IBOutlet weak var labelDate: UILabel!
    
    
    var ticket: Ticket? {
        didSet {
            labelTitle.text = ticket?.title
            if ticket?.worker?.firstName != "" {
                labelWorker.text = ticket?.worker?.firstName
            } else {
                labelWorker.text = "None worker"
            }
            if ticket?.worker?.price != "" {
                labelPrice.text = ticket?.worker?.price
            } else {
                labelPrice.text = "None price"
            }
            // Load profile worker
            if ticket?.user?.profileImage?.imageUrl! != "" {
                let profileUser = ticket?.user?.profileImage?.imageUrl!
                HandleUtil.loadImageViewWithUrl(profileUser!, imageView: imageViewWorker)
                imageViewWorker.layer.cornerRadius = 5
                imageViewWorker.clipsToBounds = true
            } else {
                imageViewWorker.image = UIImage(named: "profile_default")
            }
            // Load ticket image 
            if ticket?.imageOne?.imageUrl! != "" {
                let imageTicket = ticket?.imageOne?.imageUrl!
                HandleUtil.loadImageViewWithUrl(imageTicket!, imageView: imageViewTicket)
                imageViewTicket.layer.cornerRadius = 5
                imageViewTicket.clipsToBounds = true
            } else {
                imageViewTicket.image = UIImage(named: "no_image")
            }
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

}
