//
//  CategoryCell.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    @IBOutlet weak var categoryIconImageView: UIImageView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    var isChosen = false {
        didSet {
            self.backgroundColor = isChosen ? AppThemes.appColorTheme : UIColor(red: 88.0/255.0, green: 180.0/255.0, blue: 164.0/255.0, alpha: 0.1)
            categoryLabel.textColor = isChosen ? UIColor.blackColor() : UIColor.darkGrayColor()
        }
    }
    
    //@IBOutlet weak var backgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        categoryLabel.font = AppThemes.helveticaNeueLight13
        categoryLabel.textAlignment = .Center
        
        self.layer.cornerRadius = 10.0
    }
}
