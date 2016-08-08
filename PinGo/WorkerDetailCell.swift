//
//  WorkerDetailCell.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/9/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class WorkerDetailCell: UITableViewCell {
    @IBOutlet weak var workerProfileImageView: UIImageView!
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var workerRatingLabel: UILabel!
    @IBOutlet weak var workerHourlyRateLabel: UILabel!
    @IBOutlet weak var workerDistanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func onPickWorker(sender: AnyObject) {
    }
    
    

}
