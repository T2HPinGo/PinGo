//
//  DetailTicketViewController.swift
//  PinGo
//
//  Created by Cao Thắng on 9/1/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class DetailTicketViewController: UIViewController {
    
    // ImageView
    @IBOutlet weak var imageViewPicker: UIImageView!
    
    @IBOutlet weak var imageViewOne: UIImageView!
    
    @IBOutlet weak var imageViewTwo: UIImageView!
    
    @IBOutlet weak var imageViewThree: UIImageView!
    
    @IBOutlet weak var viewImageOne: UIView!
    
    @IBOutlet weak var viewImageTwo: UIView!
    
    @IBOutlet weak var viewImageThree: UIView!
    
    // View Info
    
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var labelDateBegin: UILabel!
    
    @IBOutlet weak var labelTimeBegin: UILabel!
    
    @IBOutlet weak var labelDescription: UILabel!
    
    
    @IBOutlet weak var labelPrice: UILabel!
    
    var ticket: Ticket?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        uploadDataToView()
        viewImageOne.layer.cornerRadius = 5
        viewImageTwo.layer.cornerRadius = 5
        viewImageThree.layer.cornerRadius = 5
       
    }
    override func viewDidAppear(animated: Bool) {
        initOpacityBarView()
        initViewImageActions()
        AppThemes.configViewGradientAppBarColor(viewImageOne)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension DetailTicketViewController {
    // MARK: - Upload data to view
    func uploadDataToView() {
        // View Info
        labelTitle.text = ticket?.title!
        if ticket?.descriptions != "" {
            labelDescription.text = ticket?.descriptions
        } else {
            labelDescription.text  = "There is no descriptions"
        }
        if ticket?.worker?.price != "" {
            labelPrice.text = ticket?.worker?.price
        } else {
            labelPrice.text  = "$ No price"
        }
        
        // ImageView Picker
        if ticket?.imageOne?.imageUrl! != "" {
            let imageTicket = ticket?.imageOne?.imageUrl!
            HandleUtil.loadImageViewWithUrl(imageTicket!, imageView: imageViewPicker)
        } else {
            imageViewPicker.image = UIImage(named: "no_image")
        }
        // View ImageViews
        imageViewOne.layer.cornerRadius = 5
        
        
        
        if ticket?.imageOne?.imageUrl! != "" {
            let imageTicket = ticket?.imageOne?.imageUrl!
            HandleUtil.loadImageViewWithUrl(imageTicket!, imageView: imageViewOne)
            imageViewOne.layer.cornerRadius = 5
            imageViewOne.clipsToBounds = true
        } else {
            imageViewOne.image = UIImage(named: "no_image")
            imageViewOne.layer.cornerRadius = 5
            imageViewOne.clipsToBounds = true
        }
        
        if ticket?.imageTwo?.imageUrl! != "" {
            let imageTicket = ticket?.imageOne?.imageUrl!
            HandleUtil.loadImageViewWithUrl(imageTicket!, imageView: imageViewTwo)
            imageViewTwo.layer.cornerRadius = 5
            imageViewTwo.clipsToBounds = true
        } else {
            imageViewTwo.image = UIImage(named: "no_image")
            imageViewTwo.layer.cornerRadius = 5
            imageViewTwo.clipsToBounds = true
        }
        
        if ticket?.imageThree?.imageUrl! != "" {
            let imageTicket = ticket?.imageOne?.imageUrl!
            HandleUtil.loadImageViewWithUrl(imageTicket!, imageView: imageViewThree)
            imageViewThree.layer.cornerRadius = 5
            imageViewThree.clipsToBounds = true
        } else {
            imageViewThree.image = UIImage(named: "no_image")
            imageViewThree.layer.cornerRadius = 5
            imageViewThree.clipsToBounds = true
        }
        
        
    }
    // MARK: initOpacityBarView
    func initOpacityBarView(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }
    // MARK: declare ViewActions
    func viewImageOneAction(sender: AnyObject){
        clearViewImages()
        showImageViewPicker(viewImageOne, imageViewPick: imageViewOne)
    }
    
    func viewImageTwoAction(sender: AnyObject){
        clearViewImages()
        showImageViewPicker(viewImageTwo, imageViewPick: imageViewTwo)
    }
    
    func viewImageThreeAction(sender: AnyObject){
        clearViewImages()
        showImageViewPicker(viewImageThree, imageViewPick: imageViewThree)
    }
    
    // MARK: init view actions
    func initViewImageActions() {
        let gestureImageOne = UITapGestureRecognizer(target: self, action: #selector(DetailTicketViewController.viewImageOneAction(_:)))
        viewImageOne.addGestureRecognizer(gestureImageOne)
        
        let gestureImageTwo = UITapGestureRecognizer(target: self, action: #selector(DetailTicketViewController.viewImageTwoAction(_:)))
        viewImageTwo.addGestureRecognizer(gestureImageTwo)
        
        let gestureImageThree = UITapGestureRecognizer(target: self, action: #selector(DetailTicketViewController.viewImageThreeAction(_:)))
        viewImageThree.addGestureRecognizer(gestureImageThree)
    }
    // MARK: init view hidden and show
    func clearViewImages(){
        removeSuperLayverView(viewImageOne)
        removeSuperLayverView(viewImageTwo)
        removeSuperLayverView(viewImageThree)
    }
    func showImageViewPicker(viewPick: UIView, imageViewPick: UIImageView) {
        AppThemes.configViewGradientAppBarColor(viewPick)
        imageViewPicker.image = imageViewPick.image
    }
    func removeSuperLayverView(view: UIView){
        if view.layer.sublayers?.count > 0 {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = view.bounds
            gradient.colors = [UIColor.clearColor().CGColor,UIColor.clearColor().CGColor]
            view.layer.sublayers![0] = gradient
        }
        
    }
}
