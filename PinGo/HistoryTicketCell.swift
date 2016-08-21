//
//  HistoryTicketCell.swift
//  PinGo
//
//  Created by Cao Thắng on 8/21/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class HistoryTicketCell: UITableViewCell {
    @IBOutlet weak var labelUsername: UILabel!

    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelDateEnd: UILabel!
    @IBOutlet weak var ImageViewCategory: UIImageView!
    
    @IBOutlet weak var imageViewTicket: UIImageView!
    @IBOutlet weak var imageViewRaiting: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    var ticket: Ticket? {
        didSet{
            labelTitle.text = ticket?.title!
            labelDateEnd.text = HandleUtil.changeUnixDateToNSDate((ticket?.createdAt)!)
            labelUsername.text = ticket?.user?.getFullName()
            if ticket?.user?.profileImage?.imageUrl! != "" {
                let profileUser = ticket?.user?.profileImage?.imageUrl!
                HandleUtil.loadImageViewWithUrl(profileUser!, imageView: imageViewProfile)
                imageViewProfile.layer.cornerRadius = 5
                imageViewProfile.clipsToBounds = true
            }
            if ticket?.imageOne?.imageUrl! != "" {
                let imageTicket = ticket?.imageOne?.imageUrl!
                HandleUtil.loadImageViewWithUrl(imageTicket!, imageView: imageViewTicket)
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
