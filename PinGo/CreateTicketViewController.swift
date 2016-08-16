//
//  CreateTicketViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import Alamofire

class CreateTicketViewController: UIViewController {
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
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: T2HTextViewWithPlaceHolder!
    
    @IBOutlet weak var urgentSwitch: UISwitch!
    
    @IBOutlet weak var paymentMethodView: UIView!
    
    @IBOutlet weak var findWorkerView: UIView!
    
    var image: UIImage?  //store image that picked
    var currentImage: Int! //store the index of current image picker
    
    var currentCategoryIndex = -1 //store current selected category index, set to -1 to avoid crash no cell has been sellected
    
    var collectionViewHidden = true //store the hidden stage of collectionView, initially hidden
    
    var newTicket: Ticket?
    
    var ticketTitle = ""
    let descriptionText = ""
    
     //MARK: - Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.keyboardDismissMode = .OnDrag
        newTicket = Ticket()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionViewHeightConstraints.constant = 0

        setupAppearance()
        
        addGesture()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowWorkerListSegue" {
            let biddingViewController = segue.destinationViewController as! TicketBiddingViewController
            biddingViewController.newTicket = self.newTicket
        }
    }
    
    //MARK: - Helpers
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
        
        //add gesture for 
        let findWorkerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(performListWorkerSegue(_:)))
        findWorkerView.addGestureRecognizer(findWorkerGestureRecognizer)
    }
    
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
                //self.categoryLabel.text = self.currentCategoryIndex == -1 ? "Choose Category" : TicketCategory.categoryNames[self.currentCategoryIndex]
                
                if self.currentCategoryIndex == -1 {
                    self.categoryLabel.text = "Choose Category"
                } else {
                    self.presentCategoryUpdateAnimation()
                }
            })
        }
    }
    
    
    //make rotation effect for chooseCategoryView when selected
    func presentCategoryUpdateAnimation() {
        let offset: CGFloat = chooseCategoryView.frame.height * 2
//        chooseCategoryView.transform = CGAffineTransformMakeTranslation(1, offset)
//        chooseCategoryView.transform = CGAffineTransformMakeScale(1, 0.1)
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
        }, completion: { _ in
        })
        
//        UIView.animateWithDuration(5.0, delay: 0.5, options: .CurveEaseIn, animations: {
//            self.chooseCategoryView.transform = CGAffineTransformMakeTranslation(0, -offset)
//            self.chooseCategoryView.transform = CGAffineTransformMakeScale(1, 0.1)
//            }, completion: nil)
        
        
        
        
        
        
//        UIView.animateKeyframesWithDuration(duration, delay: 0, options: .CalculationModeCubic, animations: {
//            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.334, animations: {
//                toView.transform = CGAffineTransformMakeScale(1.2, 1.2)
//            })
//            UIView.addKeyframeWithRelativeStartTime(0.334, relativeDuration: 0.333, animations: {
//                toView.transform = CGAffineTransformMakeScale(0.9, 0.9)
//            })
//            UIView.addKeyframeWithRelativeStartTime(0.667, relativeDuration: 0.333, animations: {
//                toView.transform = CGAffineTransformMakeScale(1.0, 1.0)
//            })
//            }, completion: { finished in
//                transitionContext.completeTransition(finished)
//        })

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
    
    func performListWorkerSegue(gestureRecognizer: UIGestureRecognizer) {
        
        newTicket?.category = categoryLabel.text!
        newTicket?.title = titleTextField.text!
        newTicket?.ticketDescription = descriptionTextView.text
        newTicket?.user = UserProfile.currentUser
        newTicket?.status = Status.Pending
        newTicket?.urgent = urgentSwitch.on
        newTicket?.worker = Worker()
        newTicket?.location = Location()
        
        let parameters = parametersTicket(newTicket!)
        
        
        Alamofire.request(.POST, "\(API_URL)\(PORT_API)/v1/ticket", parameters: parameters).responseJSON { response  in
            print("--- Socket Client")
            let JSON = response.result.value as? [String:AnyObject]
            //print(JSON)
            let JSONobj = JSON!["data"]! as! [String : AnyObject]
            self.newTicket = Ticket(data: JSONobj)
            //print(JSONobj)
            SocketManager.sharedInstance.pushCategory(JSON!["data"]! as! [String : AnyObject])
            self.performSegueWithIdentifier("ShowWorkerListSegue", sender: gestureRecognizer)
        }

       /*
         let JSONobj = JSON!["data"] as? [String: AnyObject]
         let user = UserProfile(data: JSONobj!)
         print(user.email)
         UserProfile.currentUser = user
         let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        */
    }
    
    
    //_____________________________
    func parametersTicket(ticket: Ticket) -> [String: AnyObject]{
//        let parameters = [
//            "title": "\((ticket.title)!)",
//            "category": "\((ticket.category)!)",
//            "imageOneUrl": "\((ticket.imageOne?.imageUrl)!)",
//            "imageTwoUrl": "\((ticket.imageTwo?.imageUrl)!)",
//            "imageThreeUrl": "\((ticket.imageThree?.imageUrl)!)",
//            "status" : "\((ticket.status)!)",
//            "idUser": "\((ticket.user!.id)!)",
//            "nameOfUser": "\((ticket.user?.username)!)",
//            "phoneOfUser": "\((ticket.user!.phoneNumber)!)",
//            "imageUserUrl": "\((ticket.user!.profileImage!.imageUrl)!)",
//            "address": "\((ticket.location!.address)!)",
//            "city": "\((ticket.location!.city)!)",
//            "latitude": "\((ticket.location!.latitude)!)",
//            "longtitude": "\((ticket.location!.longitute)!)",
//            "idWorker": "\((ticket.worker?.id)!)",
//            "nameOfWorker": "\((ticket.worker?.username)!)",
//            "phoneOfWorker": "\((ticket.worker?.phoneNumber)!)",
//            "imageWorkerUrl": "\((ticket.worker?.profileImage!.imageUrl)!)",
//            "urgent": "\((ticket.urgent)!)",
//            "width": 400,
//            "height": 300,
//            "widthOfProfile": 60,
//            "heightOfProfile": 60
//        ]
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
        parameters["urgent"] = (ticket.urgent)!
        parameters["width"] = 400
        parameters["height"] = 300
        parameters["widthOfProfile"] = 60
        parameters["heightOfProfile"] = 60

//        let parameters = [
//            "title": (ticket.title)!,
//            "category": (ticket.category)!,
//            "imageOneUrl": (ticket.imageOne?.imageUrl)!,
//            "imageTwoUrl": (ticket.imageTwo?.imageUrl)!,
//            "imageThreeUrl": (ticket.imageThree?.imageUrl)!,
//            "status" : (ticket.status)!,
//            "idUser": (ticket.user!.id)!,
//            "nameOfUser": (ticket.user?.username)!,
//            "phoneOfUser": (ticket.user!.phoneNumber)!,
//            "imageUserUrl": (ticket.user!.profileImage!.imageUrl)!,
//            "address": (ticket.location!.address)!,
//            "city": (ticket.location!.city)!,
//            "latitude": (ticket.location!.latitude)!,
//            "longtitude": (ticket.location!.longitute)!,
//            "idWorker": (ticket.worker?.id)!,
//            "nameOfWorker": (ticket.worker?.username)!,
//            "phoneOfWorker": (ticket.worker?.phoneNumber)!,
//            "imageWorkerUrl": (ticket.worker?.profileImage!.imageUrl)!,
//            "urgent": (ticket.urgent)!,
//            "width": 400,
//            "height": 300,
//            "widthOfProfile": 60,
//            "heightOfProfile": 60
//        ]

        return parameters
    }
    
    
    //_______________________________
    
    
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
        ticketDetailViewHeightConstraint.constant = topAndBottomMargin*2 + verticalDistanceBetweenViews*5 + takePhotoView2HeightConstraint.constant + titleTextField.bounds.height + descriptionTextView.bounds.height + urgentSwitch.bounds.height + paymentMethodView.bounds.height + findWorkerView.bounds.height
        
        //place holder
        titleTextField.placeholder = "Enter your title"
        descriptionTextView.placeholder = "Enter description"
        
        //chooseCategoryView
        chooseCategoryView.backgroundColor = UIColor(red: 42.0/255.0, green: 58.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        chooseCategoryView.layer.cornerRadius = 20.0
        chooseCategoryView.layer.borderColor = UIColor(red: 0.0/255.0, green: 180.0/255.0, blue: 136.0/255.0, alpha: 1.0).CGColor
        chooseCategoryView.layer.borderWidth = 2.0
        categoryLabel.textColor = UIColor(red: 0.0/255.0, green: 180.0/255.0, blue: 136.0/255.0, alpha: 1.0)

        
        //collectionView
        collectionView.backgroundColor = UIColor.clearColor()
        
        //ticketDetailView
        ticketDetailView.alpha = 0.0
        ticketDetailView.backgroundColor = UIColor.clearColor()
    }

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
            break
        case 2:
            pickedImageView2.image = image
            PinGoClient.uploadImage((self.newTicket?.imageTwo)!, image: image, uploadType: "ticket")  ////upload image to server to save it on server
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

extension CreateTicketViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
    }
}

extension CreateTicketViewController: UITextViewDelegate {
    func textViewDidEndEditing(textView: UITextView) {
    }
}



