//
//  TittleAndDescriptionViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/7/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import Foundation

let isLTRLanguage = UIApplication.sharedApplication().userInterfaceLayoutDirection == .LeftToRight

class TittleAndDescriptionViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tittleTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    let lightGreyColor = UIColor(red: 197/255, green: 205/255, blue: 205/255, alpha: 1.0)
    let darkGreyColor = UIColor(red: 52/255, green: 42/255, blue: 61/255, alpha: 1.0)
    let overcastBlueColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupThemeColors()
    }
    
    //
    func setupThemeColors() {
        
        self.tittleTextField.placeholder     = NSLocalizedString("Title", tableName: "SkyFloatingLabelTextField", comment: "placeholder for person title field")
        self.tittleTextField.selectedTitle   = NSLocalizedString("Title", tableName: "SkyFloatingLabelTextField", comment: "selected title for person title field")
        self.tittleTextField.title           = NSLocalizedString("Title", tableName: "SkyFloatingLabelTextField", comment: "title for person title field")
        
        self.applySkyscannerTheme(self.tittleTextField)
        
        self.tittleTextField.delegate = self
    }
    
    func applySkyscannerTheme(textField: SkyFloatingLabelTextField) {
        
        textField.tintColor = overcastBlueColor
        
        textField.textColor = darkGreyColor
        textField.lineColor = lightGreyColor
        
        textField.selectedTitleColor = overcastBlueColor
        textField.selectedLineColor = overcastBlueColor
        
        // Set custom fonts for the title, placeholder and textfield labels
        textField.titleLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
        textField.placeholderFont = UIFont(name: "AppleSDGothicNeo-Light", size: 18)
        textField.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)
    }
    
    //
    var isSubmitButtonPressed = false
    
    var showingTitleInProgress = false
    
    @IBAction func submitButtonDown(sender: AnyObject) {
        self.isSubmitButtonPressed = true
        
        if !self.tittleTextField.hasText() {
            self.showingTitleInProgress = true
            self.tittleTextField.setTitleVisible(true, animated: true, animationCompletion: self.showingTitleInAnimationComplete)
            self.tittleTextField.highlighted = true
        }
    }
    
    func showingTitleInAnimationComplete() {
        // If a field is not filled out, display the highlighted title for 0.3 seco
        let displayTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
        dispatch_after(displayTime, dispatch_get_main_queue(), {
            self.showingTitleInProgress = false
            if(!self.isSubmitButtonPressed) {
                self.hideTitleVisibleFromFields()
            }
        })
    }
    
    func hideTitleVisibleFromFields() {
        self.tittleTextField.setTitleVisible(false, animated: true)
       
        self.tittleTextField.highlighted = false
    }
}
