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
    @IBOutlet weak var categoryImageView: UIImageView!
    
    @IBOutlet weak var requestTitleLabel: UILabel!
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var workerImageView: UIImageView!
    
    @IBOutlet weak var workerNameLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
