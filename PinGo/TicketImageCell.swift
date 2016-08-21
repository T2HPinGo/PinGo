//
//  TicketImageCell.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/21/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class TicketImageCell: UICollectionViewCell {
    
    @IBOutlet weak var ticketImageView: UIImageView!
    
    var imageUrl: String! {
        didSet {
            HandleUtil.loadImageViewWithUrl(imageUrl, imageView: ticketImageView)
        }
    }
}
