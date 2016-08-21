//
//  EditUserProfileViewController.swift
//  PinGo
//
//  Created by Haena Kim on 8/12/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire
@objc protocol EditUserProfileViewControllerDelegate {
    optional func editUserProfileViewController(editUserProfileViewController: EditUserProfileViewController, didUpdateProfile profile: [String:AnyObject])
}

class EditUserProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextViewDelegate {
    
    let offsetHeaderViewStopTranformations :CGFloat = 40.0
    let distanceHeaderBotAndUserNameLabel: CGFloat = 35.0
    let offsetNameLabelBelowHeaderView: CGFloat = 95.0
    @IBOutlet var headerBackgroundImageView:UIImageView!
    @IBOutlet var headerBackgroundBlurImageView:UIImageView!
    
    @IBOutlet weak var headerNameLabel: UILabel!
    
    @IBOutlet weak var headerPhoneNumber: UILabel!
    // HeaderView
    @IBOutlet weak var headerView: UIView!
    
    // HeadeView Of TableiView
    @IBOutlet weak var imageViewProfile: UIImageView!
    
    @IBOutlet weak var imageViewRating: NSLayoutConstraint!
    
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelFullname: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var buttonCall: UIButton!
    
    @IBOutlet weak var labelPhoneNumber: UILabel!
    // TableView
    @IBOutlet weak var tableView: UITableView!
    // Another Variables
    var tickets = [Ticket]()
    var userProfile: UserProfile?
    weak var delegate: EditUserProfileViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        tableView.delegate = self
        //        tableView.dataSource = self
        
        logoutButton.backgroundColor = AppThemes.cellColors[2]
        // Do any additional setup after loading the view.
       
        if userProfile == nil {
            userProfile = UserProfile.currentUser
        }
        initTableView()
        loadDataForView()
    
        if UserProfile.currentUser!.isWorker {
            loadDataFromApi(UserProfile.currentUser!.id!)
        }
        initOpacityBarView()
    }
    
    override func viewDidAppear(animated: Bool) {
        initHeaderView()
    }
    @IBAction func logoutAction(sender: AnyObject) {
        
        UserProfile.currentUser = nil
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.logout()
        
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
// MARK: TableView
extension EditUserProfileViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HistoryTicketCell") as! HistoryTicketCell
        cell.ticket = tickets[indexPath.row]
        return cell
    }
    func initTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clearColor()

    }
}
// MARK: Load data for view
extension EditUserProfileViewController {
    func loadDataForView() {
        if userProfile?.profileImage?.imageUrl! != "" {
            let profileUser = userProfile?.profileImage?.imageUrl!
            HandleUtil.loadImageViewWithUrl(profileUser!, imageView: imageViewProfile)
            imageViewProfile.layer.cornerRadius = 5
            imageViewProfile.clipsToBounds = true
        }
        labelFullname.text = userProfile?.getFullName()
        labelUsername.text = userProfile?.username!
        labelEmail.text = userProfile?.email!
        labelPhoneNumber.text = userProfile?.phoneNumber!
        headerPhoneNumber.text = userProfile?.phoneNumber!
        headerNameLabel.text = userProfile?.getFullName()
        imageViewProfile.layer.borderColor = UIColor.whiteColor().CGColor
        imageViewProfile.layer.borderWidth = 2
    }
    func loadDataFromApi(idWorker: String) {
        var parameters = [String : AnyObject]()
        parameters["statusTicket"] = Status.Approved.rawValue
        parameters["idWorker"] = idWorker
        Alamofire.request(.POST, "\(API_URL)\(PORT_API)/v1/historytickets", parameters: parameters).responseJSON { response  in
            let JSONArrays  = response.result.value!["data"] as! [[String: AnyObject]]
            print(JSONArrays)
            for JSONItem in JSONArrays {
                let ticket = Ticket(data: JSONItem)
                 self.tickets.append(ticket)
                
            }
            self.tableView.reloadData()
        }
    }
    func initOpacityBarView(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }
    func initHeaderView(){
        
        // Init Background View
        headerBackgroundImageView = UIImageView(frame: headerView.bounds)
        headerBackgroundBlurImageView = UIImageView(frame: headerView.bounds)
        // Blur Image
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = headerBackgroundBlurImageView.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        headerBackgroundBlurImageView.addSubview(blurEffectView)
        headerBackgroundBlurImageView?.alpha = 0.0
        
        headerBackgroundImageView?.image = UIImage(named: "iron_man")
        headerBackgroundBlurImageView?.image = UIImage(named: "iron_man")
        headerBackgroundImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        headerBackgroundBlurImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        // Should add background view below SubView
        headerView.insertSubview(headerBackgroundImageView, belowSubview: headerNameLabel)
        headerView.insertSubview(headerBackgroundBlurImageView, belowSubview: headerNameLabel)
        headerView.clipsToBounds = true
    }

}

// Update header view when is scrolling
extension EditUserProfileViewController {
    func updateHeaderView(offSetScrollView: CGFloat) {
        var profileImageTransform = CATransform3DIdentity
        var headerViewTransform = CATransform3DIdentity
        // SrollView Pull Down
        if offSetScrollView < 0 {
            let headerViewScaleFactor :CGFloat = -(offSetScrollView) / headerView.bounds.height
            let headerViewSize = ((headerView.bounds.height * (1.0 + headerViewScaleFactor)) - headerView.bounds.height)/2.0
            // 3D Translate
            headerViewTransform = CATransform3DTranslate(headerViewTransform, 0, headerViewSize, 0)
            headerViewTransform = CATransform3DScale(headerViewTransform, 1.0 + headerViewScaleFactor, 1.0 + headerViewScaleFactor, 0)
            // Blur effect
            headerBackgroundBlurImageView?.alpha = min(1.0, (-offSetScrollView)/(headerView.bounds.height/4))
            headerView.layer.transform = headerViewTransform
            
        } else {  // Scroll To UP OR Down
            
            // 3D Translate View
            headerViewTransform = CATransform3DTranslate(headerViewTransform, 0, max(-offsetHeaderViewStopTranformations, -offSetScrollView), 0)
            let labelNameTransform = CATransform3DMakeTranslation(0, max(-distanceHeaderBotAndUserNameLabel, offsetNameLabelBelowHeaderView - offSetScrollView), 0)
            let labelTweetTransform = CATransform3DMakeTranslation(0, max(-distanceHeaderBotAndUserNameLabel + 1, offsetNameLabelBelowHeaderView - offSetScrollView + 1), 0)
            headerNameLabel.layer.transform = labelNameTransform
            headerPhoneNumber.layer.transform = labelTweetTransform
            // Blur Image
            headerBackgroundBlurImageView?.alpha = min (1.0, (offSetScrollView - offsetNameLabelBelowHeaderView)/distanceHeaderBotAndUserNameLabel)
            
            // Scale profile imageView with slow animation
            let profileScaleFactor = (min(offsetHeaderViewStopTranformations, offSetScrollView)) / imageViewProfile.bounds.height / 1.4
            
            let profileSize = ((imageViewProfile.bounds.height * (1.0 + profileScaleFactor)) - imageViewProfile.bounds.height) / 2.0
            profileImageTransform = CATransform3DTranslate(profileImageTransform, 0, profileSize, 0)
            profileImageTransform = CATransform3DScale(profileImageTransform, 1.0 - profileScaleFactor, 1.0 - profileScaleFactor, 0)
            
            // Set Higher priority for Profile Image and Header View
            if offSetScrollView <= offsetHeaderViewStopTranformations {
                
                // Scroll Down profileView should have the priority higher than headerView
                if imageViewProfile.layer.zPosition < headerView.layer.zPosition{
                    headerView.layer.zPosition = 0
                }
                
            }else {
                //Scroll Up profileView should have the priority lower than headerView
                if imageViewProfile.layer.zPosition >= headerView.layer.zPosition{
                    headerView.layer.zPosition = 2
                }
            }
        }
        headerView.layer.transform = headerViewTransform
        imageViewProfile.layer.transform = profileImageTransform
    }
    
}
extension EditUserProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView(scrollView.contentOffset.y)
    }
}
