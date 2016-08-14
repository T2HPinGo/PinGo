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
        
        setupAppearance()
        
    }
    
    @IBAction func onPickWorker(sender: AnyObject) {
    }
    
    //MARK: - Helpers
    func setupAppearance() {
        //profile image
        workerProfileImageView.layer.cornerRadius = workerProfileImageView.frame.width / 2
        workerProfileImageView.clipsToBounds = true
    }

}
