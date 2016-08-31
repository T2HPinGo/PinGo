//
//  MapViewController.swift
//  PinGo
//
//  Created by Haena Kim on 8/15/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire
import CoreLocation

class MapViewController: UIViewController, UISearchDisplayDelegate, GMSMapViewDelegate {
    //MARK: - Outlets and Variables
    @IBOutlet weak var testView: GMSMapView!
    
    @IBOutlet weak var findButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableSlideUpButton: UIButton!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cancelTicketBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var filterBatButtonItem: UIBarButtonItem!
    
    var newTicket: Ticket!
    
    var workerList: [Worker] = []
    
    //get location
    var locationManager = CLLocationManager()
    
    //get search results
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController!
    var resultView: UITextView?
    
    var didFindMyLocation = false
    var placesClient = GMSPlacesClient()
    var userMarker: GMSMarker?
    var isFirstTimeUseMap = true
    var flagCount = 0
    var location :Location?
    
    var currentCategoryIndex = -1 //store current selected category index, set to -1 to avoid crash no cell has been sellected
    
    var isShowingTableView = false //check if worker list in table view is shown or not
    
    var activityIndicatorView: NVActivityIndicatorView! = nil
    
    let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
    let apiKey = "AIzaSyBgEYM4Ho-0gCKypMP5qSfRoGCO1M1livw"
    
    //MARK: - Outlets for subview
    var subViews: UIView!
    
    var categoryView: UIView!
    var categoryLabel: UILabel!
    var categoryIconImageView: UIImageView!
    
    var dateView: UIView!
    var dateLabel: UILabel!
    var timeLabel: UILabel!
    var calendarIconImageView: UIImageView!
    var clockIconImageView: UIImageView!
    
    var paymentView: UIView!
    var paymentLabel: UILabel!
    var paymentIconImageView: UIImageView!
    
    var addDetailView: UIView!
    var detailLabel: UILabel!
    var detailIconImageView: UIImageView!
    
    //MARK: - Load Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newTicket = Ticket()
        
        location = Location()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        //locationManager.distanceFilter = 200
        
        testView.myLocationEnabled = true
        testView.delegate = self
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController.delegate = self
        self.definesPresentationContext = true //// When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.transform = CGAffineTransformMakeTranslation(0, view.frame.height) //add the start stage for collection View
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableViewHeightConstraint.constant = (view.frame.height - 69) / 2
        tableView.transform = CGAffineTransformMakeTranslation(0, tableViewHeightConstraint.constant) //add the start stage for table View
        tableSlideUpButton.transform = CGAffineTransformMakeTranslation(0, tableViewHeightConstraint.constant) ////add the start stage for tableViewSlideUpButton
        
        roundedButton(findButton)
        roundedButton(tableSlideUpButton)

        self.flagCount = 1
        setupSubView()
        
        cancelTicketBarButtonItem.enabled = false
        
        
        //load worker list
        SocketManager.sharedInstance.getWorkers { (worker, idTicket) in
            if self.newTicket!.id != idTicket {
                return
            }
            self.workerList.append(worker)
            self.tableView.reloadData()
            if self.workerList.count > 0 {
                self.stopActivityAnimating()
            }
            //self.updateNumberOfWorkersFound()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        testView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
//        removeObserver:fromObjectsAtIndexes:forKeyPath:context:
        testView.removeObserver(self, forKeyPath: "myLocation")
    }
    
    //MARK: - Navigations
    @IBAction func unwindFromDateTimePicker(segue: UIStoryboardSegue) {
        if let dateTimePickerViewController = segue.sourceViewController as? DateTimePickerViewController {
            if let chosenDate = dateTimePickerViewController.chosenDate {
                self.dateLabel.text = getStringFromDate(chosenDate, withFormat: DateStringFormat.DD_MMM_YYYY)
                self.dateLabel.sizeToFit()
                
                newTicket?.dateCreated = chosenDate
            } else {
                self.dateLabel.text = "Today"
            }
        }
    }
    
    @IBAction func unwindFromAddingDetail(segue: UIStoryboardSegue) {
        if let addDetailViewController = segue.sourceViewController as? AddTicketDetailViewController {
            if let title = addDetailViewController.titleTextField.text {
                newTicket!.title = title
                self.detailLabel.text = title != "" ? title : "Ticket Title"
                self.detailLabel.sizeToFit()
            }
            
            if let ticketDescription = addDetailViewController.descriptionTextView.text {
                if ticketDescription == "Enter Description (Optional)" {
                    newTicket!.descriptions = ""
                } else {
                    newTicket!.descriptions = ticketDescription
                }
                print(description)
            }
            
            let pickedImages = addDetailViewController.images
            
            //load image to server depending on how many pictures that user chose before
            switch pickedImages.count {
            case 1:
                PinGoClient.uploadImage((self.newTicket?.imageOne)!, image: pickedImages[0], uploadType: "ticket") //upload image to server to save it on server
            case 2:
                PinGoClient.uploadImage((self.newTicket?.imageOne)!, image: pickedImages[0], uploadType: "ticket")
                PinGoClient.uploadImage((self.newTicket?.imageTwo)!, image: pickedImages[1], uploadType: "ticket")
            case 3:
                PinGoClient.uploadImage((self.newTicket?.imageOne)!, image: pickedImages[0], uploadType: "ticket")
                PinGoClient.uploadImage((self.newTicket?.imageTwo)!, image: pickedImages[1], uploadType: "ticket")
                PinGoClient.uploadImage((self.newTicket?.imageThree)!, image: pickedImages[2], uploadType: "ticket")
            default:
                break
            }
        }
    }
    
    //MARK: - Helpers
    func roundedButton(button: UIButton){
        button.backgroundColor = AppThemes.appColorTheme
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.size.width/2
        button.clipsToBounds = true
    }
    
    //
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            //if user hasn't find any location, show current location
            let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation //find current location
            
            testView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 13.0)
            testView.settings.myLocationButton = true
            
            self.location!.longitute = myLocation.coordinate.longitude
            self.location!.latitude = myLocation.coordinate.latitude
            

            let position = CLLocationCoordinate2DMake(self.location?.longitute as! Double, self.location?.latitude as! Double)
            self.userMarker = GMSMarker(position: position)
            //            self.userMarker!.snippet = "\(self.address)"
            //            self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            self.userMarker!.tracksInfoWindowChanges = true
            self.userMarker!.map = self.testView
            
            self.testView.selectedMarker = self.userMarker
            self.userMarker!.icon = UIImage(named:"marker")
            
            didFindMyLocation = true
        }
        
    }
    
    func setupSubView(){
        subViews = UIView(frame: CGRectMake(10, 75, view.bounds.width - 20, 134.0))
        subViews.clipsToBounds = true
        
        //customize search bar
        let searchBar = searchController?.searchBar
        let locationAddress = location!.address!
        searchBar?.placeholder = "\(locationAddress)"
        searchBar!.sizeToFit()
        let searchTextField = searchBar!.valueForKey("_searchField") as? UITextField
        searchTextField?.backgroundColor = UIColor.whiteColor()
        searchTextField?.textColor = AppThemes.appColorTheme
        searchController?.searchBar.barTintColor = UIColor.whiteColor()
        searchController?.searchBar.tintColor = AppThemes.appColorTheme
        subViews.addSubview(searchBar!)
        
        let iconHeight: CGFloat = 13
        
        let spaceBetweenViews: CGFloat = 1.0
        let viewHeight: CGFloat = 44
        let viewWidthSmall: CGFloat = (view.frame.width - 20 - 2*spaceBetweenViews) / 3
        let labelMargin: CGFloat = 5
        let labelHeight:CGFloat = 20
        let labelWidth: CGFloat = viewWidthSmall - 2*labelMargin - iconHeight - 3
        
        
        //Category
        categoryView = UIView(frame: CGRect(x: 0, y: 45, width: viewWidthSmall, height: viewHeight))
        categoryView.backgroundColor = UIColor.whiteColor()
        let pickCategoryGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickCategory(_:)))
        categoryView.addGestureRecognizer(pickCategoryGestureRecognizer)
        
        categoryLabel = UILabel(frame: CGRect(x: labelMargin + iconHeight + 3, y: labelMargin, width: labelWidth, height: categoryView.frame.height - 2*labelMargin))
        categoryLabel.text = "Choose Category"
        categoryLabel.numberOfLines = 2
        categoryLabel.font = AppThemes.helveticaNeueLight13
        
        categoryIconImageView = UIImageView(frame: CGRect(x: labelMargin, y: categoryView.frame.height/2 - iconHeight/2, width: iconHeight, height: iconHeight))
        categoryIconImageView.image = UIImage(named: "category")
        
        categoryView.addSubview(categoryIconImageView)
        categoryView.addSubview(categoryLabel)
        subViews.addSubview(categoryView)
        
        //Date & Time picker
        dateView = UIView(frame: CGRect(x: viewWidthSmall + spaceBetweenViews, y: 45 , width: viewWidthSmall, height: viewHeight))
        dateView.backgroundColor = UIColor.whiteColor()
        let pickTimeGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickTime(_:)))
        dateView.addGestureRecognizer(pickTimeGestureRecognizer)
        
        dateLabel = UILabel(frame: CGRect(x: labelMargin + iconHeight + 3 , y: labelMargin, width: labelWidth, height: labelHeight))
        dateLabel.text = "Today"
        dateLabel.font = AppThemes.helveticaNeueLight13
        dateLabel.sizeToFit()
        
        
        timeLabel = UILabel(frame: CGRect(x: labelMargin + iconHeight + 3, y: dateView.frame.height - labelMargin - dateLabel.frame.height, width: labelWidth, height: labelHeight))
        timeLabel.text = "ASAP"
        timeLabel.font = AppThemes.helveticaNeueLight13
        timeLabel.sizeToFit()
        
        calendarIconImageView = UIImageView(frame: CGRect(x: labelMargin, y: 3, width: iconHeight, height: iconHeight))
        calendarIconImageView.image = UIImage(named: "calendar")
        
        clockIconImageView = UIImageView(frame: CGRect(x: labelMargin, y: timeLabel.center.y - iconHeight/2 - 2, width: iconHeight, height: iconHeight))
        clockIconImageView.image = UIImage(named: "clock")
        
        dateView.addSubview(self.calendarIconImageView)
        dateView.addSubview(self.clockIconImageView)
        dateView.addSubview(self.dateLabel)
        dateView.addSubview(self.timeLabel)
        subViews.addSubview(self.dateView)
        
        
        //Payment
        paymentView = UIView(frame: CGRect(x: 2*viewWidthSmall + 2*spaceBetweenViews, y: 45, width: viewWidthSmall, height: viewHeight))
        paymentView.backgroundColor = UIColor.whiteColor()
        
        paymentLabel = UILabel(frame: CGRect(x: labelMargin + iconHeight + 3, y: categoryView.frame.height/2 - iconHeight/2, width: labelWidth, height: labelHeight))
        paymentLabel.text = "Cash"
        paymentLabel.font = AppThemes.helveticaNeueLight13
        paymentLabel.sizeToFit()
        
        paymentIconImageView = UIImageView(frame: CGRect(x: labelMargin, y: categoryView.frame.height/2 - iconHeight/2, width: iconHeight, height: iconHeight))
        paymentIconImageView.image = UIImage(named: "cash")
        
        paymentView.addSubview(self.paymentIconImageView)
        paymentView.addSubview(self.paymentLabel)
        subViews.addSubview(self.paymentView)
        
        //Title + Description + photos
        addDetailView = UIView(frame: CGRect(x: 0, y: 2*viewHeight + 2*spaceBetweenViews, width: view.frame.width - 20, height: viewHeight))
        addDetailView.backgroundColor = UIColor.whiteColor()
        let addDetailGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addTicketDetail(_:)))
        addDetailView.addGestureRecognizer(addDetailGestureRecognizer)
        
        detailIconImageView = UIImageView(frame: CGRect(x: labelMargin, y: addDetailView.frame.height/2 - iconHeight/2 - 2, width: iconHeight, height: iconHeight))
        detailIconImageView.image = UIImage(named: "compose")
        
        detailLabel = UILabel(frame: CGRect(x: labelMargin + iconHeight + 3, y: addDetailView.frame.height/2 - iconHeight/2, width: addDetailView.frame.width - 2*labelMargin - iconHeight - 3, height: labelHeight))
        detailLabel.text = "Ticket Title"
        detailLabel.font = AppThemes.helveticaNeueLight13
        detailLabel.sizeToFit()
        
        addDetailView.addSubview(detailIconImageView)
        addDetailView.addSubview(detailLabel)
        subViews.addSubview(self.addDetailView)
        
        //shadow
        shadowForViews([categoryView, dateView], withHorizontalOffset: 1, withVerticleOffset: -1)
        shadowForViews([paymentView, addDetailView], withHorizontalOffset: 0, withVerticleOffset: -1)
        
        self.view.addSubview(subViews)
    }
    
    func shadowForViews(views: [UIView], withHorizontalOffset offsetX: CGFloat, withVerticleOffset offsetY: CGFloat) {
        for view in views {
            view.layer.shadowOffset = CGSizeMake(offsetX, offsetY); //default is (0.0, -3.0)
            view.layer.shadowColor = UIColor.lightGrayColor().CGColor//default is black
            view.layer.shadowRadius = 1.0 //default is 3.0
            view.layer.shadowOpacity = 1.0 //default is 0.0
        }
    }
    
    func adjustViewsWhenChoosingCategory() {
        //move the category collectionview up so it's visible
        UIView.animateWithDuration(0.3, animations: {
            self.collectionView.transform = CGAffineTransformIdentity
        }, completion: nil)
        
        //move the map up so the collectionview doesn't block the map
        UIView.animateWithDuration(0.3, animations: {
            self.testView.transform = CGAffineTransformMakeTranslation(0, -self.collectionView.frame.height)
        }, completion: nil)
        
        //move the findButton up so it doesn't block the current location button
        UIView.animateWithDuration(0.3, animations: {
            self.findButton.transform = CGAffineTransformMakeTranslation(0, -self.collectionView.frame.height)
        }, completion: nil)
    }
    
    func adjustViewsWhenFinishChoosingCategory() {
        //make the category collection view and the map go back to originnal position while picking time and date
        UIView.animateWithDuration(0.3, animations: {
            self.collectionView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.height)
        }, completion: nil)
        
        UIView.animateWithDuration(0.3, animations: {
            self.testView.transform = CGAffineTransformIdentity
        }, completion: nil)
        
        UIView.animateWithDuration(0.3, animations: {
            self.findButton.transform = CGAffineTransformIdentity
        }, completion: nil)
    }
    
    // TODO: refractor this. put into model
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
    
    //check if user enter enough information
    func didEnterRequiredInformation() -> Bool {
        //if the category hasn/t been chosen OR no photo has been chosen OR no tile has been entered
//        if newTicket!.title == "" || newTicket?.imageOne?.imageUrl == "" {
//            return false
//        }
        return true
    }
    
    func startLoadingIndicator() {
        let transparentView = UIView(frame: UIScreen.mainScreen().bounds)
        transparentView.backgroundColor = UIColor(red: 248.0/255.0, green: 193.0/255.0, blue: 133.0/255.0, alpha: 0.95)
        
        //set up positin & size for the indicator
        let frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallScaleMultiple, color: UIColor.whiteColor(), padding: 80)
        activityIndicatorView.transform = CGAffineTransformMakeScale(1, 0.3)
        activityIndicatorView.center = transparentView.center
        activityIndicatorView.hidesWhenStopped = true
        
        //marker
        let markerIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        markerIconImageView.center = CGPoint(x: activityIndicatorView.center.x, y: activityIndicatorView.center.y - 25)
        markerIconImageView.image = UIImage(named: "marker")
        
        //shadow for the marker
        let shadowVIew = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        shadowVIew.layer.cornerRadius = shadowVIew.frame.width / 2
        shadowVIew.backgroundColor = UIColor.darkGrayColor()
        shadowVIew.center = CGPoint(x: markerIconImageView.center.x, y: markerIconImageView.center.y + 25)
        shadowVIew.transform = CGAffineTransformMakeScale(1, 0.3)
        
        transparentView.addSubview(activityIndicatorView)
        transparentView.addSubview(shadowVIew)
        transparentView.addSubview(markerIconImageView)
        UIApplication.sharedApplication().keyWindow!.addSubview(transparentView)
        activityIndicatorView.startAnimation()
        
        
        
        
        
        
        
        
        
        
        //
        let containerViews = UIView(frame: CGRectMake(0, 0, view.bounds.width - 20, 134.0))
        containerViews.center = CGPoint(x: transparentView.center.x, y: 200)
        containerViews.clipsToBounds = true
        
        let iconHeight: CGFloat = 13
        
        let spaceBetweenViews: CGFloat = 1.0
        let viewHeight: CGFloat = 44
        let viewWidthSmall: CGFloat = (view.frame.width - 20 - 2*spaceBetweenViews) / 3
        let labelMargin: CGFloat = 5
        let labelHeight:CGFloat = 20
        let labelWidth: CGFloat = viewWidthSmall - 2*labelMargin - iconHeight - 3
        
        //Date label
        let loadingDateView = UIView(frame: CGRect(x: 0, y: viewHeight + 1, width: viewWidthSmall, height: viewHeight))
        dateView.backgroundColor = UIColor.whiteColor()
        
        let loadingDateLabel = UILabel(frame: CGRect(x: labelMargin + iconHeight + 3 , y: loadingDateView.frame.height/2 - labelHeight/2, width: labelWidth, height: labelHeight))
        loadingDateLabel.text = "Today"
        loadingDateLabel.font = AppThemes.helveticaNeueLight13
        loadingDateLabel.sizeToFit()
        let loadingCalendarIconImageView = UIImageView(frame: CGRect(x: labelMargin, y: 3, width: iconHeight, height: iconHeight))
        loadingCalendarIconImageView.image = UIImage(named: "calendar")
        
        loadingDateView.addSubview(self.calendarIconImageView)
        loadingDateView.addSubview(self.dateLabel)
        
        //time label
        let loadingTimeView = UIView(frame: CGRect(x: viewWidthSmall + 1, y: viewHeight + 1, width: viewWidthSmall, height: viewHeight))
        loadingTimeView.backgroundColor = UIColor.whiteColor()
        
        let loadingTimeLabel = UILabel(frame: CGRect(x: labelMargin + iconHeight + 3 , y: loadingTimeView.frame.height/2 - labelHeight/2, width: labelWidth, height: labelHeight))
        loadingTimeLabel.text = "ASAP"
        loadingTimeLabel.font = AppThemes.helveticaNeueLight13
        loadingTimeLabel.sizeToFit()
        let loadingClockIconImageView = UIImageView(frame: CGRect(x: labelMargin, y: loadingTimeLabel.center.y - iconHeight/2 - 2, width: iconHeight, height: iconHeight))
        loadingClockIconImageView.image = UIImage(named: "clock")
        
        loadingTimeView.addSubview(loadingClockIconImageView)
        loadingTimeView.addSubview(loadingTimeLabel)
        containerViews.addSubview(loadingTimeView)
        
        //Payment
        let loadingPaymentView = UIView(frame: CGRect(x: 2*viewWidthSmall + 2*spaceBetweenViews, y: viewHeight + 1, width: viewWidthSmall, height: viewHeight))
        loadingPaymentView.backgroundColor = UIColor.whiteColor()
        
        let loadingPaymentLabel = UILabel(frame: CGRect(x: labelMargin + iconHeight + 3, y: loadingPaymentView.frame.height/2 - iconHeight/2, width: labelWidth, height: labelHeight))
        loadingPaymentLabel.text = "Cash"
        loadingPaymentLabel.font = AppThemes.helveticaNeueLight13
        loadingPaymentLabel.sizeToFit()
        
        let loadingPaymentIconImageView = UIImageView(frame: CGRect(x: labelMargin, y: loadingPaymentView.frame.height/2 - iconHeight/2, width: iconHeight, height: iconHeight))
        loadingPaymentIconImageView.image = UIImage(named: "cash")
        
        loadingPaymentView.addSubview(loadingPaymentIconImageView)
        loadingPaymentView.addSubview(loadingPaymentLabel)
        containerViews.addSubview(loadingPaymentView)
        
        //Title
        let loadingTitleView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width - 20, height: viewHeight))
        loadingTitleView.backgroundColor = UIColor.whiteColor()
        
        let loadingTitleIconImageView = UIImageView(frame: CGRect(x: labelMargin, y: loadingTitleView.frame.height/2 - iconHeight/2 - 2, width: iconHeight, height: iconHeight))
        loadingTitleIconImageView.image = UIImage(named: "compose")
        
        let loadingTitleLabel = UILabel(frame: CGRect(x: labelMargin + iconHeight + 3, y: loadingTitleView.frame.height/2 - iconHeight/2, width: loadingTitleView.frame.width - 2*labelMargin - iconHeight - 3, height: labelHeight))
        loadingTitleLabel.text = "Ticket Title"
        loadingTitleLabel.font = AppThemes.helveticaNeueLight13
        loadingTitleLabel.sizeToFit()
        
        loadingTitleView.addSubview(loadingTitleIconImageView)
        loadingTitleView.addSubview(loadingTitleLabel)
        containerViews.addSubview(loadingTitleView)
        
        transparentView.addSubview(containerViews)
    }
    
    func buttonTapped(sender: UIButton) {
        if activityIndicatorView.animating {
            activityIndicatorView.stopAnimation()
        } else {
            activityIndicatorView.startAnimation()
        }
    }
    
    
    //MARK: - Actions & Gestures
    @IBAction func panGestureMap(sender: UIPanGestureRecognizer) {
        // Absolute (x,y) coordinates in parent view (parentView should be
        // the parent view of the tray)
        let point = sender.locationInView(testView)
        
        if sender.state == UIGestureRecognizerState.Began {
            print("Gesture began at: \(point)")
        } else if sender.state == UIGestureRecognizerState.Changed {
            print("Gesture changed at: \(point)")
        } else if sender.state == UIGestureRecognizerState.Ended {
            print("Gesture ended at: \(point)")
        }
    }
    
    func pickTime(gestureRecognizer: UIGestureRecognizer) {
        let storyboard = UIStoryboard(name: "MapStoryboard", bundle: nil)
        let calendarPopupViewController = storyboard.instantiateViewControllerWithIdentifier("DateTimePickerViewController") as! DateTimePickerViewController
        
        //nextTime user tap on this, the calendar will appear exactly what user chose before
        calendarPopupViewController.chosenDate = newTicket?.dateCreated
        
        self.presentViewController(calendarPopupViewController, animated: true, completion: nil)
        
        adjustViewsWhenFinishChoosingCategory()
    }
    
    func pickCategory(gestureRecognizer: UIGestureRecognizer) {
        adjustViewsWhenChoosingCategory()
    }
    
    func addTicketDetail(gestureRecognizer: UIGestureRecognizer) {
        let storyboard = UIStoryboard(name: "MapStoryboard", bundle: nil)
        let detailPopupViewController = storyboard.instantiateViewControllerWithIdentifier("AddTicketDetailViewController") as! AddTicketDetailViewController
        
        //nextTime user tap on this, the calendar will appear exactly what user chose before
        detailPopupViewController.titleString = newTicket!.title!
        detailPopupViewController.descriptionString = newTicket!.descriptions
        
        self.presentViewController(detailPopupViewController, animated: true, completion: nil)
        
        adjustViewsWhenFinishChoosingCategory()
    }
    
    @IBAction func onTableSlideUp(sender: UIButton) {
        
        //if tableview is hidden, slide it up, if it is shown then slide it down
        if !isShowingTableView {
            UIView.animateKeyframesWithDuration(0.6, delay: 0, options: .CalculationModeCubic, animations: {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.33, animations: {
                    self.tableView.transform = CGAffineTransformIdentity
                    self.tableSlideUpButton.transform = CGAffineTransformIdentity
                })
                
                //fliping effect for tableSlideUpButton
                UIView.addKeyframeWithRelativeStartTime(0.33, relativeDuration: 0.63, animations: {
                    self.tableSlideUpButton.transform = CGAffineTransformMakeScale(1, 0.1)
                    self.tableSlideUpButton.setImage(UIImage(named: "down"), forState: .Normal)
                })
                
                UIView.addKeyframeWithRelativeStartTime(0.67, relativeDuration: 0.33, animations: {
                    self.tableSlideUpButton.transform = CGAffineTransformIdentity
                })
                }, completion: { finished in
                    self.isShowingTableView = !self.isShowingTableView
            })
        } else {
            UIView.animateKeyframesWithDuration(0.6, delay: 0, options: .CalculationModeCubic, animations: {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.33, animations: {
                    self.tableView.transform = CGAffineTransformMakeTranslation(0, self.tableViewHeightConstraint.constant)
                    self.tableSlideUpButton.transform = CGAffineTransformMakeTranslation(0, self.tableViewHeightConstraint.constant)
                })
                
                //fliping effect for tableSlideUpButton
                UIView.addKeyframeWithRelativeStartTime(0.33, relativeDuration: 0.63, animations: {
                    //self.tableSlideUpButton.transform = CGAffineTransformMakeScale(1, 0.1)
                    self.tableSlideUpButton.setImage(UIImage(named: "up"), forState: .Normal)
                })
                
                UIView.addKeyframeWithRelativeStartTime(0.67, relativeDuration: 0.33, animations: {
                    //self.tableSlideUpButton.transform = CGAffineTransformMakeScale(1, 1)
                })
                }, completion: { finished in
                    self.isShowingTableView = !self.isShowingTableView
            })
        }
    }
    
    @IBAction func onFindWorker(sender: UIButton) {
        if !didEnterRequiredInformation() {
            let alert = UIAlertController(title: "Ticket Invalid", message: "All required information must be entered before proceding to the next step", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        } else {
            //cancelTicketBarButtonItem.enabled = false //enable the cancel ticket button when the ticket is already push to server
            //self.startLoadingAnimation()
            startLoadingIndicator()
            
            newTicket?.category = categoryLabel.text!
            newTicket?.user = UserProfile.currentUser
            newTicket?.location = self.location
            newTicket?.status = Status.Pending
            newTicket?.worker = Worker()
            
            let parameters = parametersTicket(newTicket!)
            
            Alamofire.request(.POST, "\(API_URL)\(PORT_API)/v1/ticket", parameters: parameters).responseJSON { response  in
                
                if response.result.value != nil {
                    let JSON = response.result.value as? [String:AnyObject]
                    let JSONobj = JSON!["data"]! as! [String : AnyObject]
                    self.newTicket = Ticket(data: JSONobj)
                    SocketManager.sharedInstance.pushCategory(JSON!["data"]! as! [String : AnyObject])
                    
                    
                    

                    //self.stopActivityAnimating()
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
    }
    
    @IBAction func onCancelTicket(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Cancel This Ticket", message: "This process can not be undone. Tap OK to proceed", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { _ in
            
            // Delete this ticket to database and remove it to socket chanel
            let url = "\(API_URL)\(PORT_API)/v1/ticket/\(self.newTicket!.id!)"
            Alamofire.request(.DELETE, url, parameters: nil).responseJSON { response  in
                print(response.result)
                var JSON = self.newTicket.dataJson
                JSON!["status"] = Status.Cancel.rawValue
                SocketManager.sharedInstance.pushCategory(JSON!)
                
                self.dismissViewControllerAnimated(true, completion: nil)
                //self.navigationController?.popToRootViewControllerAnimated(true)
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func onFilter(sender: UIBarButtonItem) {
    }
    
    
    //MARK: - Google Map API
//    func currentLocation(){
////            self.locatewithCoordinate(self.currentlocation_long, Latitude: self.currentlocation_latitude, Title: "current location")
////            let position = CLLocationCoordinate2DMake(self.currentlocation_latitude, self.currentlocation_long)
//            
////            self.labelAddress.text = self.location!.address
//        
//    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        if (userMarker != nil && flagCount > 0) {
            flagCount = 2
            let url = NSURL(string: "\(baseUrl)latlng=\(position.target.latitude),\(position.target.longitude)&key=\(apiKey)")
            Alamofire.request(.GET, url!, parameters: nil).responseJSON { response  in
                if response.response != nil {
                    let json = response.result.value as! NSDictionary
                    if let result = json["results"] as? NSArray {
                        self.userMarker?.map = nil
                        if let address = result[0]["address_components"] as? NSArray {
                            let number = address[0]["short_name"] as! String
                            let street = address[1]["short_name"] as! String
                            let city = address[2]["short_name"] as! String
                            let state = address[4]["short_name"] as! String
                            //let zip = address[6]["short_name"] as! String
                            print("\n\(number) \(street), \(city), \(state)")
                            self.location!.address = "\(number) \(street), \(city), \(state)"
                            //                        self.labelAddress.text = self.address
                            let locationAddressShort = "\(number) \(street), \(city)"
                            self.searchController!.searchBar.placeholder = locationAddressShort
                            //                        self.labelAddress.text = self.location!.address
                            self.userMarker = GMSMarker(position: position.target)
                            //                        self.userMarker!.title = "Setup Location"
                            //                            self.userMarker!.snippet = "\(self.address)"
                            //                        self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
                            
                            
                            let imageV = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                            imageV.image = UIImage(named: "dog")
                            
                            let mask = CALayer()
                            mask.contents = UIImage(named: "marker")!.CGImage
                            mask.contentsGravity = kCAGravityResizeAspect
                            mask.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
                            mask.anchorPoint = CGPoint(x: 0.5, y: 0)
                            mask.position = CGPoint(x: imageV.frame.size.width/2, y: 0)
                            
                            imageV.layer.mask = mask
                            imageV.layer.borderWidth = 5
                            imageV.layer.borderColor = AppThemes.appColorTheme.CGColor
                            
                            
                            
                            
                            
                            self.userMarker!.iconView = imageV
                            
                            
                            

                            self.userMarker!.tracksInfoWindowChanges = true
                            self.userMarker!.map = self.testView
                            self.testView.selectedMarker = self.userMarker
                            
                        }
                    }
                }
            }
        }
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        if (flagCount != 1) {
            self.userMarker!.map = nil
            self.userMarker = GMSMarker(position: position.target)
//            self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            self.userMarker!.tracksInfoWindowChanges = true
            self.userMarker!.map = self.testView
            self.userMarker!.icon = UIImage(named: "marker")
            self.testView.selectedMarker = nil
//            self.userMarker?.snippet = "\(self.address)"
            flagCount += 1
//            self.labelAddress.text = self.location!.address
//            UINavigationBar.appearance().barTintColor = UIColor.clearColor()
        }
    }

    func locatewithCoordinate (long: NSNumber, Latitude lat: NSNumber, Title title:String ){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            let camera = GMSCameraPosition.cameraWithLatitude(lat as Double, longitude: long as Double, zoom: 16)
            self.testView.camera = camera
        }
    }
}


// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
//            testView.myLocationEnabled = true
//            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        print("error location Manager")
    }
    
//    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError) {
//        print("error location Manager")
//    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let userLocation = locations[0]
//        
//        let location_default = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
////        currentlocation_latitude = location.latitude
////        currentlocation_long = location.longitude
//        location!.latitude = location_default.latitude
//        location!.longitute = location_default.longitude
//        
//        print(location_default)
//        print(location!)
    
        locationManager.stopUpdatingLocation()
    }
}

extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        searchController?.active = false
        // Do something with the selected place.
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress!)
        print("Place attributions: ", place.attributions)
        
        locatewithCoordinate(place.coordinate.longitude, Latitude: place.coordinate.latitude, Title: place.formattedAddress!)
        self.searchController?.searchBar.placeholder = place.name
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: NSError){
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.searchController?.searchBar.placeholder = ""
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
}

//MARK: - EXTENSION: UICollectionView
extension MapViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCell", forIndexPath: indexPath) as! CategoryCell
        cell.categoryLabel.text = TicketCategory.categoryNames[indexPath.item]
        cell.categoryIconImageView.image =  UIImage(named: TicketCategory.categoryIcons[indexPath.item])
        cell.isChosen = indexPath.row == currentCategoryIndex ? true : false
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        currentCategoryIndex = indexPath.row
        self.categoryLabel.text = TicketCategory.categoryNames[currentCategoryIndex]
        self.categoryIconImageView.image = UIImage(named: TicketCategory.categoryIcons[currentCategoryIndex])
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

// MARK: - TableView data source and delegate
extension MapViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workerList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkerDetailCell", forIndexPath: indexPath) as! WorkerDetailCell
        
        cell.worker = workerList[indexPath.row]
        cell.ticket = newTicket!
        cell.mapViewController = self
        return cell
    }
    
}

//MARK: - EXTENSION: UISearchControllerDelegate
extension MapViewController: UISearchControllerDelegate {
    func willPresentSearchController(searchController: UISearchController) {
        adjustViewsWhenFinishChoosingCategory()
    }
}

//MARK: EXTENSION: NVActivityIndicator - Loading Wheel Effect
extension MapViewController: NVActivityIndicatorViewable {
    
    func startLoadingAnimation() {
        let size = CGSize(width: 30, height:30)
        
        startActivityAnimating(size, message: nil, type: .BallTrianglePath)
    }
}