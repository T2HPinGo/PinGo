//
//  WorkerHistoryCell.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/9/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class WorkerHistoryCell: UITableViewCell {
    @IBOutlet weak var ticketTitleLabel: UILabel!
    @IBOutlet weak var customerRatingLabel: UILabel!
    @IBOutlet weak var dateFixedLabel: UILabel!
    @IBOutlet weak var hourlyRateLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
