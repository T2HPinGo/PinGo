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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        categoryLabel.font = AppThemes.helveticaNeueRegular15
        categoryLabel.textAlignment = .Left
        
        self.backgroundColor = UIColor.blueColor()
    }
}
