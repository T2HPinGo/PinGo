//
//  RequestStatusCell.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class RequestStatusCell: UITableViewCell {
    //MARK: - Outlets and Variables
    @IBOutlet weak var requestTitleLabel: UILabel!
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var workerImageView: UIImageView!
    
    
    
    var ticket: Ticket! {
        didSet {
            requestTitleLabel.text = ticket.title ?? ticket.category
            workerNameLabel.text = ticket.worker?.name
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            dateCreatedLabel.text = formatter.stringFromDate(ticket.dateCreated!)
        }
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAppearance()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Helpers
    func setupAppearance(){
        //worker profile image
        workerImageView.layer.cornerRadius = workerImageView.frame.width / 2
        workerImageView.layer.masksToBounds = true
        
        //font
        requestTitleLabel.font = AppThemes.helveticaNeueRegular17
        workerNameLabel.font = AppThemes.helveticaNeueRegular17
        dateCreatedLabel.font = AppThemes.helveticaNeueRegular14
        
        //allignment
        requestTitleLabel.textAlignment = .Left
        workerNameLabel.textAlignment = .Center
        dateCreatedLabel.textAlignment = .Center
    }

}
