//
//  EditUserProfileViewController.swift
//  PinGo
//
//  Created by Haena Kim on 8/12/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

@objc protocol EditUserProfileViewControllerDelegate {
    optional func editUserProfileViewController(editUserProfileViewController: EditUserProfileViewController, didUpdateProfile profile: [String:AnyObject])
}

class EditUserProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var profileImage: UIButton!
    
    @IBOutlet weak var profileBackgroundView: UIView!

    @IBOutlet weak var firstname: UILabel!
    @IBOutlet weak var lastname: UILabel!
    @IBOutlet weak var phonenumber: UILabel!
    @IBOutlet weak var email: UILabel!
    
    let imagePicker = UIImagePickerController()
    var isPaymentCollapsed = true
    var isHistoryCollapsed = true
    var isSubscriptionCollapsed = true
    weak var delegate: EditUserProfileViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        tableView.delegate = self
//        tableView.dataSource = self
        
        
        // Do any additional setup after loading the view.
    }

    @IBAction func logoutAction(sender: AnyObject) {
        
        UserProfile.currentUser = nil
        
        NSNotificationCenter.defaultCenter().postNotificationName(UserProfile.userDidLogOutNotification, object: nil)

        
    }
    
    @IBAction func addProfileImage(sender: AnyObject) {
        print("camera on")
        
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.PhotoLibrary){
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .PhotoLibrary
            
            presentViewController(imagePicker, animated: true, completion: nil)
            
            //        self.performSegueWithIdentifier("tagSegue", sender: nil)
        }else{
            imagePicker.sourceType = .PhotoLibrary
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        //        let edittedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        
        profileImage.setImage(pickedImage, forState: .Normal)
        profileBackgroundView.backgroundColor = UIColor(patternImage: pickedImage!)
    
        let blurEffect = UIBlurEffect(style: .Light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = profileBackgroundView.bounds
        profileBackgroundView.addSubview(blurredEffectView)
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.clipsToBounds = true
        
        self.profileImage.layer.borderWidth = 0.4
        self.profileImage.layer.borderColor = UIColor.blackColor().CGColor
        
        
        dismissViewControllerAnimated(true, completion: nil)
        
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

//extension EditUserProfileViewController:UITableViewDataSource, UITableViewDelegate{
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 4
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section {
//        case 0: return 1
//        case 1: return 2
//        case 2: return 3
////        case 3: return categories.count + 1
//        default: return 0
//        }
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        switch indexPath.section {
//        case 0:
//            // payment
//            let cell = tableView.dequeueReusableCellWithIdentifier("PaymentCell", forIndexPath: indexPath) as! PaymentCell
//            
//            cell.delegate = self
//            
//            return cell
//            
//        case 1:
//            // Radius area
//            let cell = tableView.dequeueReusableCellWithIdentifier("DropDownCell", forIndexPath: indexPath) as! DropDownCell
//            cell.delegate = self
//            
//            // Set label for each cell
//            if indexPath.row == 0 {
//                cell.itemLabel.text = "Auto"
//            } else {
//                if distances[indexPath.row] == 1 {
//                    cell.itemLabel.text = "\(distances[indexPath.row]!) mile"
//                } else {
//                    cell.itemLabel.text = "\(distances[indexPath.row]!) miles"
//                }
//            }
//            
//            let radiusValue = filters["distances"] as! Float?
//            let compareRadiusValue = distances[indexPath.row]
//            DropDownCell.setRadiusIcon(indexPath.row, iconView: cell.itemIcon, radiusValue: radiusValue, compareRadiusValue: compareRadiusValue, isRadiusCollapsed: isRadiusCollapsed)
//            DropDownCell.setRadiusCellVisible(indexPath.row, cell: cell, radiusValue: radiusValue, compareRadiusValue: compareRadiusValue, isRadiusCollapsed: isRadiusCollapsed)
//            
//            return cell
//            
//        case 2:
//            // Sort area
//            let cell = tableView.dequeueReusableCellWithIdentifier("DropDownCell", forIndexPath: indexPath) as! DropDownCell
//            cell.delegate = self
//            
//            switch indexPath.row {
//            case 0:
//                cell.itemLabel.text = "Best Match"
//            case 1:
//                cell.itemLabel.text = "Distance"
//            case 2:
//                cell.itemLabel.text = "Rating"
//            default:
//                break
//            }
//            DropDownCell.setSortIcon(indexPath.row, iconView: cell.itemIcon, sortValue: getSortValue(), isSortCollapsed: isSortCollapsed)
//            DropDownCell.setSortCellVisible(indexPath.row, cell: cell, sortValue: getSortValue(), isSortCollapsed: isSortCollapsed)
//            return cell
//            
//        case 3:
//            // Category area
//            print("IndexPaath Row: \(indexPath.row)")
//            if indexPath.row != categories.count {
//                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
//                cell.switchItemLabel.text = categories[indexPath.row]["name"]
//                cell.delegate = self
//                cell.switchItemUISwitch.on = switchStates[indexPath.row] ?? false
//                SwitchCell.setCategoryCellVisible(indexPath.row, cell: cell, isCategoryCollapsed: isCategoryCollapsed, categoriesCount: categories.count)
//                return cell
//            } else {
//                // Last Cell
//                
//                let cell = tableView.dequeueReusableCellWithIdentifier("LoadAllCell", forIndexPath: indexPath) as! LoadAllCell
//                
//                let seeAllCell = UITapGestureRecognizer(target: self, action: #selector(FilterViewController.clickSeeAll(_:)))
//                cell.addGestureRecognizer(seeAllCell)
//                
//                return cell
//            }
//        default:
//            let cell = UITableViewCell()
//            return cell
//        }
//    }
//    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
//        headerView.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1)
//        
//        let titleLabel = UILabel(frame: CGRect(x: 15, y: 15, width: 320, height: 30))
//        titleLabel.font = UIFont(name: "Helvetica", size: 15)
//        
//        switch section {
//        case 0:
//            titleLabel.text = TITLE_DEAL
//        case 1:
//            titleLabel.text =  TITLE_DISTANCE
//        case 2:
//            titleLabel.text = TITLE_SORT_BY
//        case 3:
//            titleLabel.text = TITLE_CATEGORY
//        default:
//            return nil
//        }
//        headerView.addSubview(titleLabel)
//        return headerView
//    }
//    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 45
//    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        switch indexPath.section {
//        case 1:
//            if isRadiusCollapsed {
//                let radiusValue = filters["distances"] as! Float?
//                if radiusValue != distances[indexPath.row] {
//                    return 0
//                }
//            }
//        case 2:
//            if isSortCollapsed {
//                let sortValue = getSortValue()
//                if sortValue != indexPath.row {
//                    return 0
//                }
//            }
//        case 3:
//            if isCategoryCollapsed {
//                if indexPath.row > 2 && indexPath.row != categories.count {
//                    return 0
//                }
//            }
//        default:
//            break
//        }
//        
//        return HEIGHT_FOR_ROW
//    }
//}
//
