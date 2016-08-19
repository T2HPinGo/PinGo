//
//  RequestStatusCell.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

enum RequestHeight {
    case defaultHeight
    case expandedHeight
}

class RequestStatusCell: UITableViewCell {
    //MARK: - Outlets and Variables
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var requestTitleLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var ratingButton: UIButton!
    
    @IBOutlet weak var approveButton: UIButton!
//    var rating: String! {
//        didSet {
//            if rating != nil {
//                ratingButton.setImage(UIImage(named: rating), forState: .Normal)
//                ratingButton.tintColor = UIColor.whiteColor()
//                ratingButton.backgroundColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 25.0/255.0, alpha: 1.0)
//            } else {
//                ratingButton.setImage(UIImage(named: "rating"), forState: .Normal)
//                ratingButton.tintColor = UIColor.lightGrayColor()
//                ratingButton.backgroundColor = UIColor.clearColor()
//            }
//        }
//    }
    
    var ticket: Ticket! {
        didSet {
            requestTitleLabel.text = ticket.title ?? ticket.category
            
//            let formatter = NSDateFormatter()
//            formatter.dateFormat = "dd MMM yyyy"
//            dateCreatedLabel.text = formatter.stringFromDate(ticket.dateCreated!)
            let unixDate = ticket.createdAt!
            if let number = Int(unixDate) {
                let myNumber = NSNumber(integer:number)
                let epocTime = NSTimeInterval(myNumber) / 1000
                let myDate = NSDate(timeIntervalSince1970:  epocTime)
                dateCreatedLabel.text = "\(myDate)"
            } else {
                print("'\(unixDate)' did not convert to an Int")
            }
        }
    }
    
    ////MARK: - Load view
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAppearance()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - Helpers
    func setupAppearance(){
        
        //font
        requestTitleLabel.font = AppThemes.helveticaNeueRegular17
        dateCreatedLabel.font = AppThemes.helveticaNeueRegular14
        
        //allignment
        requestTitleLabel.textAlignment = .Left
        dateCreatedLabel.textAlignment = .Center
        
        //colors
        requestTitleLabel.textColor = UIColor.whiteColor()
        dateCreatedLabel.textColor = UIColor.whiteColor()
    }
    
    //MARK: - Actions
    @IBAction func onApprove(sender: UIButton) {
        
    }
    
    

}
