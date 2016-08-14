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
            self.backgroundColor = isChosen ? UIColor(white: 1.0, alpha: 0.8) : UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
            categoryLabel.textColor = isChosen ? UIColor.blackColor() : UIColor.darkGrayColor()
        }
    }
    
    //@IBOutlet weak var backgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        categoryLabel.font = AppThemes.helveticaNeueRegular15
        categoryLabel.textAlignment = .Left
        
        self.layer.cornerRadius = 10.0
        
        self.backgroundColor = UIColor.blueColor()
    }
}
