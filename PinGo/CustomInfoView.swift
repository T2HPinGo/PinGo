//
//  CustomInfoView.swift
//  PinGo
//
//  Created by Hien Quang Tran on 9/2/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import Foundation

protocol CustomInfoViewDelegate {
    func didPickWorker(string: String)
}

class CustomInfoView: UIView {
    @IBOutlet weak var workerNameLabel: UILabel!
    
    @IBOutlet weak var hourlyRateLabel: UILabel!
    
    @IBOutlet weak var pickButton: UIButton!

    @IBOutlet weak var distanceFromTicketLabel: UILabel!
    
    @IBAction func onPicked(sender: UIButton) {
        
    }
}
