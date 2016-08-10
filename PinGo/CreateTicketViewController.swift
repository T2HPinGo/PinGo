//
//  CreateTicketViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

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
    
    //MARK: - Fake data
    let categoryName = ["Electricity", "Cleanning",
                        "Plumbing", "Auto Repair", "Gardening"]
    var ticketTitle = ""
    let descriptionText = ""
    
     //MARK: - Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.keyboardDismissMode = .OnDrag
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionViewHeightConstraints.constant = 0

        setupAppearance()
        
        addGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowWorkerListSegue" {
            print("title: \(ticketTitle)")
            print("description: \(descriptionText)")
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
            collectionViewHeightConstraints.constant = 90.0
            UIView.animateWithDuration(0.5, animations: {
                self.collectionView.alpha = 1.0
            }) { finished in
                self.collectionViewHidden = false
            }
        } else {
            collectionView.alpha = 1.0
            UIView.animateWithDuration(0.5, animations: { 
                self.collectionView.alpha = 0.0
                self.collectionViewHeightConstraints.constant = 0.0
            }, completion: { finished in
                self.collectionViewHidden = true
                //if no category has been selected, keep the title as "Choose Category"
                self.categoryLabel.text = self.currentCategoryIndex == -1 ? "Choose Category" : self.categoryName[self.currentCategoryIndex]
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
    
    func performListWorkerSegue(gestureRecognizer: UIGestureRecognizer) {
        performSegueWithIdentifier("ShowWorkerListSegue", sender: gestureRecognizer)
    }
    
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
    }

}

//MARK: - EXTENSION: UICollectionView
extension CreateTicketViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCell", forIndexPath: indexPath) as! CategoryCell
        cell.categoryLabel.text = categoryName[indexPath.item]
        
        //change cell background color if the cell is selected
        let cellBackgroundColor = indexPath.row == currentCategoryIndex ? UIColor.lightGrayColor() : UIColor.blueColor()
        cell.backgroundColor = cellBackgroundColor
        
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
            pickedImageView1HeightConstraint.constant = takePhotoView2HeightConstraint.constant
            break
        case 2:
            pickedImageView2.image = image
            pickedImageView2HeightConstraint.constant = takePhotoView2HeightConstraint.constant
            break
        case 3:
            pickedImageView3.image = image
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

//ask Tan
//how to hide keyboard
//how to deal with currency
//how to make placeholder for uitextview



