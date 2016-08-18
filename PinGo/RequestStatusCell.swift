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
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var ratingButton: UIButton!
    
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var workerImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
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
    
    class var defaultHeight: CGFloat{
        get {
            return 90
        }
    }
    
    class var expandedHeight: CGFloat {
        get {
            return 180
        }
    }
    
    var ticket: Ticket! {
        didSet {
            requestTitleLabel.text = ticket.title ?? ticket.category
            workerNameLabel.text = ticket.worker?.name
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            dateCreatedLabel.text = formatter.stringFromDate(ticket.dateCreated!)
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
        
        //colors
        requestTitleLabel.textColor = UIColor.whiteColor()
        workerNameLabel.textColor = UIColor.whiteColor()
        dateCreatedLabel.textColor = UIColor.whiteColor()
        
        detailView.backgroundColor = UIColor.clearColor()   
    }
    
    func setHeight() {
        //if the height of the cell is smaller than the expanded cell height, set constraint of the detail view to 0
        detailViewHeightConstraint.constant = frame.size.height < RequestStatusCell.expandedHeight ? 0 : 90
    }
    
    func watchFrameChanges() {
        self.addObserver(self, forKeyPath: "frame", options: .New, context: nil)
    }
    
    func removeFrameChanges() {
        self.removeObserver(self, forKeyPath: "frame")
        //self.removeObserver(<#T##observer: NSObject##NSObject#>, forKeyPath: <#T##String#>)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frame" {
            setHeight()
        }
    }
    
    //MARK: - Navigations
    
    
    

}
