//
//  T2HTextViewWithPlaceHolder.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/10/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class T2HTextViewWithPlaceHolder: UITextView, UITextViewDelegate {
    
    @IBInspectable var placeholder: String? {
        didSet {
            self.text = placeholder
            self.textColor = UIColor.lightGrayColor()
        }
    }
    
    override func drawRect(rect: CGRect) {
        
    }
    
    override func awakeFromNib() {
        self.delegate = self
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 5
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
}
