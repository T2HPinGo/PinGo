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
    
    
    @IBOutlet weak var viewBackground: UIView!
    
    @IBOutlet weak var labelPriceTicket: UILabel!
    
    
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelCommentTicket: UILabel!
    var themeColor: UIColor! {
        didSet {
            viewBackground.backgroundColor = themeColor
        }
    }
    var ticket: Ticket? {
        didSet{
            labelTitle.text = ticket?.title!
            labelDateEnd.text = HandleUtil.changeUnixDateToNSDate((ticket?.createdAt)!)
            let isWorker = UserProfile.currentUser!.isWorker
            if isWorker{
                labelUsername.text = ticket?.user?.getFullName()
                labelMessage.text = "has approved ticket"
                if ticket?.user?.profileImage?.imageUrl! != "" {
                    let profileUser = ticket?.user?.profileImage?.imageUrl!
                    HandleUtil.loadImageViewWithUrl(profileUser!, imageView: imageViewProfile)
                    imageViewProfile.layer.cornerRadius = 5
                    imageViewProfile.clipsToBounds = true
                } else{
                    imageViewProfile.image = UIImage(named: "profile_default")
                }
            } else {
                labelUsername.text = ticket?.worker?.getFullName()
                labelMessage.text = "finish ticket"
                if ticket?.worker?.profileImage?.imageUrl! != "" {
                    let profileUser = ticket?.worker?.profileImage?.imageUrl!
                    HandleUtil.loadImageViewWithUrl(profileUser!, imageView: imageViewProfile)
                    imageViewProfile.layer.cornerRadius = 5
                    imageViewProfile.clipsToBounds = true
                } else{
                    imageViewProfile.image = UIImage(named: "profile_default")
                }
            }
            
            labelPriceTicket.text = ticket?.worker?.price
            labelPriceTicket.textColor = UIColor.whiteColor()
            labelCommentTicket.text = ticket?.comment
            
            if ticket?.imageOne?.imageUrl! != "" {
                let imageTicket = ticket?.imageOne?.imageUrl!
                HandleUtil.loadImageViewWithUrl(imageTicket!, imageView: imageViewTicket)
            } else {
                imageViewTicket.image = UIImage(named: "no_image")
            }
            
            imageViewRaiting.layer.cornerRadius = imageViewRaiting.frame.width / 2
            imageViewRaiting.layer.backgroundColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 25.0/255.0, alpha: 1.0).CGColor
            ImageViewCategory.image = getImageWithCategory((ticket?.category)!)
            
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
    func getImageWithCategory(category: String) -> UIImage{
        switch category {
        case Category.Electricity.rawValue:
            return UIImage(named: "Electricity")!
        case Category.Cleanning.rawValue:
            return UIImage(named: "Housekeeping")!
        case Category.AutoRepair.rawValue:
            return UIImage(named: "Maintenance")!
        case Category.Gardening.rawValue:
            return UIImage(named: "Garden")!
        case Category.Plumbing.rawValue:
            return UIImage(named: "Plumbing")!
        default:
            return UIImage()
        }
    }
}
