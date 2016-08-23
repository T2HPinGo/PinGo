//
//  CreateTicketViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire


class CreateTicketViewController: UIViewController, UITextFieldDelegate {
    //MARK: - Outlets and Variables
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var chooseCategoryView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryIconImageView: UIImageView!
    
    @IBOutlet weak var ticketDetailView: UIView!
    @IBOutlet weak var ticketDetailViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var takePhotoView1: UIView!
    @IBOutlet weak var pickedImageView1: UIImageView!
    @IBOutlet weak var pickedImageView1HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var takePhotoView2: UIView!
    @IBOutlet weak var takePhotoView2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickedImageView2: UIImageView!
    @IBOutlet weak var pickedImageView2HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var takePhotoView3: UIView!
    @IBOutlet weak var pickedImageView3: UIImageView!
    @IBOutlet weak var pickedImageView3HeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var titleTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var descriptionTextView: T2HTextViewWithPlaceHolder!
    
    @IBOutlet weak var chooseLocationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var findWorkerButton: UIButton!
        
    var image: UIImage?  //store image that picked
    var currentImage: Int! //store the index of current image picker
    
    var currentCategoryIndex = -1 //store current selected category index, set to -1 to avoid crash no cell has been sellected
    
    var collectionViewHidden = true //store the hidden stage of collectionView, initially hidden
    
    var newTicket: Ticket?
    
    var ticketTitle = ""
    let descriptionText = ""
    
    var activityIndicatorView: NVActivityIndicatorView! = nil
    
    
    struct TextFieldColorThemes {
        static let textFieldTintColor = AppThemes.appColorTheme
        static let placeholderColor = UIColor.lightGrayColor()
        static let textColor = UIColor.darkGrayColor()
        static let floatingLabelColor = AppThemes.cellColors[3]
        static let bottomLineColor = UIColor.lightGrayColor()
        static let selectedBottomLineColor = AppThemes.appColorTheme
    }
    
     //MARK: - Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.keyboardDismissMode = .OnDrag
        newTicket = Ticket()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionViewHeightConstraints.constant = 0

        setupAppearance()
        //setupLoadingIndicator()
        
        addGesture()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowWorkerListSegue" {
            let biddingViewController = segue.destinationViewController as! TicketBiddingViewController
            biddingViewController.newTicket = self.newTicket
        }
    }
    
    @IBAction func unwindFromMap(segue: UIStoryboardSegue) {
        //transfer date here
        if let mapViewController = segue.sourceViewController as? MapViewController {
            if let location = mapViewController.location {
                newTicket?.location = location
                print(location)
                print(location.longitute!)
                print(location.latitude!)
            }
            locationLabel.text = newTicket!.location?.address
        }
    }
    
    //MARK: - Helpers
    func setupAppearance() {

        collectionView.backgroundColor = UIColor.greenColor()
        collectionView.showsHorizontalScrollIndicator = false
        
        //auto resize image picker viewss depending on screen size
        let leftAndRightMargin: CGFloat = 13
        let distanceBetweenImages: CGFloat = 12
        takePhotoView2HeightConstraint.constant = (view.bounds.width - leftAndRightMargin*2 - distanceBetweenImages*2) / 3
        
        //auto resize ticket detail view depending on screen size
        let topAndBottomMargin: CGFloat = 13
        let verticalDistanceBetweenViews: CGFloat = 8
        ticketDetailViewHeightConstraint.constant = topAndBottomMargin*2 + verticalDistanceBetweenViews*5 + takePhotoView2HeightConstraint.constant + titleTextField.bounds.height + descriptionTextView.bounds.height + chooseLocationView.bounds.height + findWorkerButton.bounds.height
        
        //titleTextField
        titleTextField.placeholder = NSLocalizedString("Enter Title Here", tableName: "SkyFloatingLabelTextField", comment: "placeholder in the textField")
        titleTextField.selectedTitle   = NSLocalizedString("Title", tableName: "SkyFloatingLabelTextField", comment: "title when selected")
        titleTextField.title = NSLocalizedString("Title", tableName: "SkyFloatingLabelTextField", comment: "title when not selected")
        titleTextField.placeholderColor = TextFieldColorThemes.placeholderColor
        
        titleTextField.tintColor = TextFieldColorThemes.textFieldTintColor
        titleTextField.textColor = TextFieldColorThemes.textColor
        
        titleTextField.lineColor = TextFieldColorThemes.bottomLineColor
        titleTextField.selectedLineColor = TextFieldColorThemes.selectedBottomLineColor
        
        titleTextField.selectedTitleColor = TextFieldColorThemes.floatingLabelColor
        
        titleTextField.titleLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 13)
        titleTextField.placeholderFont = UIFont(name: "AppleSDGothicNeo-Light", size: 16)
        titleTextField.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)

        //descriptionTextField
        descriptionTextView.placeholder = "Enter Description (Optional)"
        descriptionTextView.backgroundColor = UIColor.clearColor()
        descriptionTextView.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        
        //chooseCategoryView
        chooseCategoryView.backgroundColor = AppThemes.appColorTheme
        chooseCategoryView.layer.cornerRadius = 10
        categoryLabel.font = AppThemes.helveticaNeueRegular17
        categoryLabel.textColor = UIColor.whiteColor()
        
        //takePhotoView1/2/3
        setupPhotoView(takePhotoView1)
        setupPhotoView(takePhotoView2)
        setupPhotoView(takePhotoView3)
        takePhotoView2.hidden = true
        takePhotoView3.hidden = true
        
        //chooseLocationView
        chooseLocationView.backgroundColor = AppThemes.appColorTheme
        chooseLocationView.layer.cornerRadius = 10
        
        //findWorker button
        findWorkerButton.layer.cornerRadius = 10.0
        findWorkerButton.backgroundColor = AppThemes.appColorTheme
        
        
        //collectionView
        collectionView.backgroundColor = UIColor.clearColor()
        
        //ticketDetailView
        ticketDetailView.alpha = 0.0
        ticketDetailView.backgroundColor = UIColor.clearColor()
    }
    
    func setupPhotoView(view: UIView) {
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = AppThemes.appColorTheme.CGColor
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.clearColor()
    }
    
    func addGesture() {
        //add gesture for chooseCategoryView
        let categoryViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showCollectionView(_:)))
        chooseCategoryView.addGestureRecognizer(categoryViewGestureRecognizer)
        
        //add gesture for imagePicker
        let firstPhotoViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showImagePicker(_:)))
        takePhotoView1.addGestureRecognizer(firstPhotoViewGestureRecognizer)
        
        let secondPhotoViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showImagePicker(_:)))
        takePhotoView2.addGestureRecognizer(secondPhotoViewGestureRecognizer)
        
        let thirdPhotoViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showImagePicker(_:)))
        takePhotoView3.addGestureRecognizer(thirdPhotoViewGestureRecognizer)
        
        //add gesture that go to the Map
        let chooseLocationGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseLocation(_:)))
        chooseLocationView.addGestureRecognizer(chooseLocationGestureRecognizer)    }
    
    //make flipping effect for chooseCategoryView when selected
    func presentCategoryUpdateAnimation() {
        let offset: CGFloat = chooseCategoryView.frame.height * 2
        self.categoryLabel.alpha = 0
        
        UIView.animateKeyframesWithDuration(0.3, delay: 0, options: .CalculationModeCubic, animations: {
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: {
                self.chooseCategoryView.transform = CGAffineTransformMakeTranslation(0, -offset)
                self.chooseCategoryView.transform = CGAffineTransformMakeScale(1, 0.1)
                self.categoryLabel.text = TicketCategory.categoryNames[self.currentCategoryIndex]
            })
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: {
                self.chooseCategoryView.transform = CGAffineTransformIdentity
                self.categoryLabel.alpha = 1
            })
        }, completion: nil)
    }
    
    //check if user enter enough information
    func didEnterRequiredInformation() -> Bool {
        //if the category hasn/t been chosen OR no photo has been chosen OR no tile has been entered
        if titleTextField.text == "" || newTicket?.imageOne == "" || takePhotoView2.hidden {
            return true
        }
        return false
    }
    
        //  MARK: - Gesture/Actions
    func showCollectionView(gestureRecognizer: UIGestureRecognizer) {
        //if the collectionView is currently hidden, then show it. Otherwise, hide it
        if collectionViewHidden {
            collectionView.alpha = 0.0
            UIView.animateWithDuration(0.3, animations: {
                self.collectionViewHeightConstraints.constant = 90.0
                self.collectionView.alpha = 1.0
                self.view.layoutIfNeeded()
            }) { finished in
                self.collectionViewHidden = false
            }
        } else {
            collectionView.alpha = 1.0
            ticketDetailView.alpha = 0.0
            UIView.animateWithDuration(0.3, animations: {
                self.collectionView.alpha = 0.0
                self.collectionViewHeightConstraints.constant = 0.0
                
                //if user haven't select category, don't show ticketDetail
                self.ticketDetailView.alpha = self.currentCategoryIndex == -1 ? 0.0 : 1.0
                self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.collectionViewHidden = true
                    //if no category has been selected, keep the title as "Choose Category"
                    if self.currentCategoryIndex == -1 {
                        self.categoryLabel.text = "Choose Category"
                    } else {
                        self.presentCategoryUpdateAnimation()
                    }
            })
        }
    }
    
    func showImagePicker(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.view == takePhotoView1 {
            currentImage = 1
        } else if gestureRecognizer.view == takePhotoView2 {
            currentImage = 2
        } else if gestureRecognizer.view == takePhotoView3 {
            currentImage = 3
        }
        pickPhotoTakingMethod()
    }
    
    @IBAction func findWorkerButtonTapped(sender: UIButton) {
        
        if didEnterRequiredInformation() {
            let alert = UIAlertController(title: "Ticket Invalid", message: "All required information must be entered before proceding to the next step", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        } else {
            
            self.startLoadingAnimation()
            
            newTicket?.category = categoryLabel.text!
            newTicket?.title = titleTextField.text!
            newTicket?.ticketDescription = descriptionTextView.text
            newTicket?.user = UserProfile.currentUser
            newTicket?.status = Status.Pending
            newTicket?.worker = Worker()
            //newTicket?.dateCreated = NSDate()
            
            let parameters = parametersTicket(newTicket!)
            
            Alamofire.request(.POST, "\(API_URL)\(PORT_API)/v1/ticket", parameters: parameters).responseJSON { response  in
                
                if response.result.value != nil {
                    let JSON = response.result.value as? [String:AnyObject]
                    let JSONobj = JSON!["data"]! as! [String : AnyObject]
                    self.newTicket = Ticket(data: JSONobj)
                    SocketManager.sharedInstance.pushCategory(JSON!["data"]! as! [String : AnyObject])
                    self.stopActivityAnimating()
                    self.performSegueWithIdentifier("ShowWorkerListSegue", sender: nil)
                } else {
                    //return an error message if cannot send request to server
                    self.stopActivityAnimating()
                    let alertController = UIAlertController(title: "Error", message: "Cannot push data to server. This could be due to internet connection. Please try again later", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(action)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
        
        /*
         let JSONobj = JSON!["data"] as? [String: AnyObject]
         let user = UserProfile(data: JSONobj!)
         print(user.email)
         UserProfile.currentUser = user
         let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         */
    }
    
    func chooseLocation (sender: AnyObject){
        let storyboard = UIStoryboard(name: "MapStoryboard", bundle: nil)
        let mapViewController = storyboard.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
        
        self.navigationController?.pushViewController(mapViewController, animated: true)
        
        if newTicket?.location != nil{
            newTicket?.location = Location()
        }
    }
    
    //_____________________________
    func parametersTicket(ticket: Ticket) -> [String: AnyObject]{
        
        var parameters = [String : AnyObject]()
        parameters["title"] = (ticket.title)!
        parameters["category"] = (ticket.category)!
        parameters["imageOneUrl"] = (ticket.imageOne?.imageUrl)!
        parameters["imageTwoUrl"] = (ticket.imageTwo?.imageUrl)!
        parameters["imageThreeUrl"] = (ticket.imageThree?.imageUrl)!
        parameters["status"] = "\((ticket.status)!)"
        parameters["idUser"] = (ticket.user!.id)!
        parameters["nameOfUser"] = (ticket.user?.username)!
        parameters["phoneOfUser"] =  (ticket.user!.phoneNumber)!
        parameters["imageUserUrl"] = (ticket.user!.profileImage!.imageUrl)!
        parameters["address"] =  (ticket.location!.address)!
        parameters["city"] =  (ticket.location!.city)!
        parameters["latitude"] =  (ticket.location!.latitude)!
        parameters["longtitude"] = (ticket.location!.longitute)!
        parameters["idWorker"] = (ticket.worker?.id)!
        parameters["nameOfWorker"] = (ticket.worker?.username)!
        parameters["phoneOfWorker"] = (ticket.worker?.phoneNumber)!
        parameters["imageWorkerUrl"] = (ticket.worker?.profileImage!.imageUrl)!
        //parameters["urgent"] = (ticket.urgent)!
        parameters["width"] = 400
        parameters["height"] = 300
        parameters["widthOfProfile"] = 60
        parameters["heightOfProfile"] = 60
        parameters["descriptions"] = ticket.descriptions
        parameters["firstnameOfUser"] = ticket.user?.firstName
        parameters["lastnameOfUser"] = ticket.user?.lastName
        parameters["firstnameOfWorker"] = ticket.worker?.firstName
        parameters["lastnameOfWorker"] = ticket.worker?.lastName

        return parameters
    }
    //_______________________________

}

//MARK: - EXTENSION: UICollectionView
extension CreateTicketViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCell", forIndexPath: indexPath) as! CategoryCell
        cell.categoryLabel.text = TicketCategory.categoryNames[indexPath.item]
        
        cell.isChosen = indexPath.row == currentCategoryIndex ? true : false
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        currentCategoryIndex = indexPath.row
        collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
        if let isSelected = cell?.selected where isSelected {
            //perform any custom deselect logic
            
            return false
        }
        
        return true
    }
}


//MARK: - EXTENSION: Image Picker
extension CreateTicketViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhotoTakingMethod() {
        //check id camera is availabel, if yes then aske user to choose between taking a photo and choose in library
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            //if camera isn't available. let user choose from library
            choosePhotoFromLibrary()
        }
    }
    
    //promt a message asking user to choose to take photo from camera or choose from library
    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default) { _ in
            self.takePhotoWithCamera()
        }
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default) { _ in
            self.choosePhotoFromLibrary()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(takePhotoAction)
        alert.addAction(chooseFromLibraryAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if let image = image {
            showImage(image)
        }
        
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showImage(image: UIImage){
        switch currentImage {
        case 1:
            pickedImageView1.image = image
            PinGoClient.uploadImage((self.newTicket?.imageOne)!, image: image, uploadType: "ticket") ////upload image to server to save it on server
            pickedImageView1HeightConstraint.constant = takePhotoView2HeightConstraint.constant
            takePhotoView2.hidden = false //make the second photo picker visible when the first one is already picked
            break
        case 2:
            pickedImageView2.image = image
            PinGoClient.uploadImage((self.newTicket?.imageTwo)!, image: image, uploadType: "ticket")  ////upload image to server to save it on server
            takePhotoView3.hidden = false //make the third photo picker visible when the second one is already picked
            pickedImageView2HeightConstraint.constant = takePhotoView2HeightConstraint.constant
            break
        case 3:
            pickedImageView3.image = image
            PinGoClient.uploadImage((self.newTicket?.imageThree)!, image: image, uploadType: "ticket") //upload image to server to save it on server
            pickedImageView3HeightConstraint.constant = takePhotoView2HeightConstraint.constant
            break
        default:
            break
        }
    }
}

extension CreateTicketViewController: NVActivityIndicatorViewable {
    func startLoadingAnimation() {
        let size = CGSize(width: 30, height:30)
        
        startActivityAnimating(size, message: nil, type: .BallTrianglePath)
    }
}


