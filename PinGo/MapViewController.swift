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

class MapViewController: UIViewController, UISearchDisplayDelegate {
    //MARK: - Outlets and Variables
    @IBOutlet weak var testView: GMSMapView!
    
    @IBOutlet weak var findButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableHeaderView: UIView!
    
    
    
    @IBOutlet weak var tableSlideUpView: UIView!
    @IBOutlet weak var numberOfWorkersFoundLabel: UILabel!
    @IBOutlet weak var tableSlideUpButton: UIButton!
    
    @IBOutlet weak var cancelTicketBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var filterBatButtonItem: UIBarButtonItem!
    
    var newTicket: Ticket!
    
    var workerList: [Worker] = []
    var distanceToTicket: [(distanceInMeters: Double, timeTravelInSeconds: Double)] = [] //save distance of the worker to the ticket
    
    //get location
    var locationManager = CLLocationManager()
    
    //get search results
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController!
    
    var placesClient = GMSPlacesClient()
    var userMarker = GMSMarker()
    
    var currentCategoryIndex = -1 //store current selected category index, set to -1 to avoid crash no cell has been sellected
    
    var isShowingTableView = false //check if worker list in table view is shown or not
    var isShowingCategoryList = false //check if the category list is shown or not
    
    var activityIndicatorView: NVActivityIndicatorView! = nil
    
    let randomMessages = ["Being nice to workers makes them work three time as effective",
                         "Always ask for the worker's ID before let them enter your house",
                         "The more details you give us, the faster we can help you",
                         "Be aware that we never ask for your PIN number or any online banking passwords over the phone or via email"]
    
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
    
    let latitudes = [48.8566667,41.8954656,51.5001524]
    let longitudes = [2.3509871,12.4823243,-0.1262362]
    
    //MARK: - Load Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //logo Pingo on the navigation bar
        let logo = UIImage(named: "PinGo_text")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        imageView.contentMode = .ScaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = logo
        self.navigationItem.titleView = imageView
        
        newTicket = Ticket()
        
        //check if users have allowed this app to access their current location
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == CLAuthorizationStatus.NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        } else if authStatus == CLAuthorizationStatus.Denied || authStatus == CLAuthorizationStatus.Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        startLocationManager() //update location
        
        testView.myLocationEnabled = true
        testView.delegate = self
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.hidesNavigationBarDuringPresentation = false
        //searchController.delegate = self
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
        tableSlideUpView.transform = CGAffineTransformMakeTranslation(0, tableViewHeightConstraint.constant) ////add the start stage for tableViewSlideUpView
        tableSlideUpView.backgroundColor = UIColor.whiteColor()
        tableSlideUpView.hidden = true //initially hide this view when there is no ticket had been created
        
        roundedButton(findButton)
        
        //filterBatButtonItem.enabled = false //intially disble filter, when there is no ticket had been created

        setupSubView()
        
        //load worker list
        SocketManager.sharedInstance.getWorkers { (worker, idTicket) in
            if self.newTicket!.id != idTicket {
                return
            }
            self.workerList.append(worker)
            
            //add a marker for the worker found and tag that marker with the index of that worker in the worker list for date transfer purpose
            if let index = self.workerList.indexOf(worker) {
                self.getMarkerForWorker(worker, atIndex: index)
            }
            
            //get distance from worker position to the ticket location
            self.getDistanceToTicket(fromWorker: worker)
            
            self.tableView.reloadData()
            if self.workerList.count > 0 {
                self.stopLoadingIndicator()
                self.updateNumberOfWorkersFound()
                self.tableSlideUpView.hidden = false
            }
        }
        
        //getdistance()
    }
    
    func getDistanceToTicket(fromWorker worker: Worker){
        //"https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(latitudes[0]),\(longitudes[0])&destinations=\(latitudes[1]),\(longitudes[1])%7C\(latitudes[2]),\(longitudes[2])&key=\(apiKey)"
        
        //https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=51.51047800000001,-0.1300343&destinations=51.50998,-0.1337&key=AIzaSyBgEYM4Ho-0gCKypMP5qSfRoGCO1M1livw
        
        //create URL request
        let baseUrl = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins="
        var urlString = ""
        if let latitude = newTicket.location?.latitude,
            let longitude = newTicket.location?.longitute,
            let workerLatitude = worker.location?.latitude,
            let workerLongitude = worker.location?.longitute {
            
            let originString = "\(latitude),\(longitude)"
            let destinationString = "\(workerLatitude),\(workerLongitude)"
            urlString = "\(baseUrl)\(originString)&destinations=\(destinationString)&key=\(apiKey)"
        }
        
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
                                   timeoutInterval: 10)
        //print(url) //TODO: - check distance matrix Url
        
        //configure session -> executed on main thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary{
                    let status = responseDictionary["status"] as! String
                    
                    //TODO: - Refeactor this, put in a new function

                    //check the status of the request before processing
                    if status == "INVALID_REQUEST" {
                        print("Invalid request")
                    } else if status == "OK" {
                        //let element = responseDictionary["row"]![0]["elements"]!![0] as! NSDictionary
                        let row = responseDictionary["rows"] as! NSArray
                        let elements = row[0]["elements"] as! NSArray
                        let element = elements[0] as! NSDictionary
                        let elementStatus = element["status"] as! String
                        
                        //sometimes the url is valid but the longitude and latigude don't exist, the distance cannot be calculated
                        if elementStatus == "NOT_FOUND" {
                            print("Distance not found")
                        } else if elementStatus == "OK" {
                            let distance = element["distance"]!["value"] as! Double
                            let time = element["duration"]!["value"] as! Double
                            
                            self.distanceToTicket.append((distance, time))
                        }
                    }
                }
            } else {
                print(error?.localizedDescription)
            }
        })
        task.resume()
    }
    
    //MARK: - Navigations
    @IBAction func unwindFromDateTimePicker(segue: UIStoryboardSegue) {
        if let dateTimePickerViewController = segue.sourceViewController as? DateTimePickerViewController {
            //chosen date
            if let chosenDate = dateTimePickerViewController.chosenDate {
                self.dateLabel.text = getStringFromDate(chosenDate, withFormat: DateStringFormat.DD_MMM_YYYY)
                self.dateLabel.sizeToFit()
            } else {
                self.dateLabel.text = "Any Day"
                self.dateLabel.sizeToFit()
            }
            
            newTicket.dateBegin = self.dateLabel.text!
            
            //chosen time
            if let chosenTime = dateTimePickerViewController.chosenTime {
                self.timeLabel.text = getStringFromDate(chosenTime, withFormat: DateStringFormat.HH_mm)
                self.timeLabel.sizeToFit()
                
                //newTicket?.dateCreated = chosenDate
            } else {
                self.timeLabel.text = "ASAP"
            }
            
            newTicket.timeBegin = self.timeLabel.text!
        }
    }
    
    @IBAction func unwindFromAddingDetail(segue: UIStoryboardSegue) {
        if let addDetailViewController = segue.sourceViewController as? AddTicketDetailViewController {
            self.newTicket = addDetailViewController.newTicket
            
            let title = newTicket.title
            self.detailLabel.text = title != "" ? title  : "Ticket Title"
            self.detailLabel.sizeToFit()
            
            if newTicket.descriptions == "Enter Description (Optional)" {
                    newTicket!.descriptions = ""
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UserFilterSegue" {
            let filterViewController = segue.destinationViewController as! UserFilterViewController
            filterViewController.workerList = self.workerList
        }
    }
    
    //MARK: - Helpers
    func updateNumberOfWorkersFound() {
        if workerList.count == 1 {
            numberOfWorkersFoundLabel.text = "1 Worker"
        } else {
            numberOfWorkersFoundLabel.text = "\(workerList.count) Workers"
        }
    }
    
    func getMarkerForWorker(worker: Worker, atIndex index: Int) {
        if let latitude = worker.location?.latitude, let longitude = worker.location?.longitute {
            let workerCoordinate = CLLocationCoordinate2DMake(latitude as Double, longitude as Double)
            
            let marker = GMSMarker(position: workerCoordinate)
            marker.map = testView
            marker.infoWindowAnchor = CGPointMake(0.5, 0.5)
            marker.accessibilityLabel = "\(index)" //tag the marker with a referrence so later you know where to get the data for this marker and show it on the info window
            
            let croppedImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            croppedImageView.contentMode = .ScaleAspectFill
            if let url = worker.profileImage?.imageUrl {
                HandleUtil.loadImageViewWithUrl(url, imageView: croppedImageView)
            } else {
                croppedImageView.image = UIImage(named: "profile_default")
            }
            
            let mask = CALayer()
            mask.contents = UIImage(named: "ic_marker_b")!.CGImage
            mask.contentsGravity = kCAGravityResizeAspect
            mask.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
            mask.anchorPoint = CGPoint(x: 0.5, y: 0)
            mask.position = CGPoint(x: croppedImageView.frame.size.width/2, y: 0)
            croppedImageView.layer.mask = mask
            marker.iconView = croppedImageView
        }
    }
    
    func roundedButton(button: UIButton){
        button.backgroundColor = AppThemes.appColorTheme
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.size.width/2
        button.clipsToBounds = true
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message:
            "Please enable location services for this app in Settings.",
                                      preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default,
                                     handler: nil)
        presentViewController(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    func setupSubView(){
        subViews = UIView(frame: CGRectMake(10, 75, view.bounds.width - 20, 134.0))
        subViews.clipsToBounds = true
        
        //customize search bar
        
        //searchController?.searchBar.sizeToFit()
        let searchTextField = searchController.searchBar.valueForKey("_searchField") as? UITextField
        searchTextField?.backgroundColor = UIColor.whiteColor()
        searchTextField?.textColor = AppThemes.appColorTheme
        searchController?.searchBar.barTintColor = UIColor.whiteColor()
        searchController?.searchBar.tintColor = AppThemes.appColorTheme
        subViews.addSubview(searchController.searchBar)
        
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
        dateLabel.text = "Any Day"
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
        parameters["dateBegin"] = ticket.dateBegin
        parameters["timeBegin"] = ticket.timeBegin
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
        if newTicket!.title == "" || newTicket?.imageOne?.imageUrl == "" || newTicket.category == "" {
            return false
        }
        return true
    }
    
    func startLoadingIndicator() {
        let transparentView = UIView(frame: UIScreen.mainScreen().bounds)
        transparentView.backgroundColor = UIColor(red: 248.0/255.0, green: 193.0/255.0, blue: 133.0/255.0, alpha: 0.95)
        //UIColor(red: 88.0/255.0, green: 180.0/255.0, blue: 164.0/255.0, alpha: 0.85)
        transparentView.restorationIdentifier = "TransparentActivityIndicatorViewContainer"
        
        
        //set up positin & size for the indicator
        let frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallScaleMultiple, color: UIColor.whiteColor(), padding: 100)
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
        
        //add a view that summarize all the ticket information
        let containerViews = UIView(frame: CGRectMake(0, 0, view.bounds.width - 20, 106.0))
        containerViews.center = CGPoint(x: transparentView.center.x, y: view.frame.height - 30 - 35 - 8 - 106/2)
        //30 is the verticle distance between bottom of the screen and the cancelButotn
        //35 is the height of cancelButton
        //8 is the verticle distance of cancelButton and the containerViews
        containerViews.clipsToBounds = true
        
        let iconHeight: CGFloat = 13
        
        let spaceBetweenViews: CGFloat = 1.0
        let viewHeight: CGFloat = 30
        let viewWidthSmall: CGFloat = (view.frame.width - 20 - 2*spaceBetweenViews) / 3
        let labelMargin: CGFloat = 5
        let labelHeight:CGFloat = 20
        let labelWidth: CGFloat = viewWidthSmall - 2*labelMargin - iconHeight - 3
        
        //Date label
        let loadingDateView = UIView(frame: CGRect(x: 0, y: viewHeight + 1, width: viewWidthSmall, height: viewHeight))
        loadingDateView.backgroundColor = UIColor.whiteColor()
        
        let loadingDateLabel = UILabel(frame: CGRect(x: labelMargin + iconHeight + 3 , y: loadingDateView.frame.height/2 - iconHeight/2, width: labelWidth, height: labelHeight))
        loadingDateLabel.text = newTicket.dateBegin
        loadingDateLabel.font = AppThemes.helveticaNeueLight13
        loadingDateLabel.sizeToFit()
        let loadingCalendarIconImageView = UIImageView(frame: CGRect(x: labelMargin, y: loadingDateView.frame.height/2 - iconHeight/2 - 2, width: iconHeight, height: iconHeight))
        loadingCalendarIconImageView.image = UIImage(named: "calendar")
        
        loadingDateView.addSubview(loadingCalendarIconImageView)
        loadingDateView.addSubview(loadingDateLabel)
        containerViews.addSubview(loadingDateView)
        
        //time label
        let loadingTimeView = UIView(frame: CGRect(x: viewWidthSmall + 1, y: viewHeight + 1, width: viewWidthSmall, height: viewHeight))
        loadingTimeView.backgroundColor = UIColor.whiteColor()
        
        let loadingTimeLabel = UILabel(frame: CGRect(x: labelMargin + iconHeight + 3 , y: loadingTimeView.frame.height/2 - iconHeight/2, width: labelWidth, height: labelHeight))
        loadingTimeLabel.text = newTicket.timeBegin
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
        loadingTitleLabel.text = newTicket.title
        loadingTitleLabel.font = AppThemes.helveticaNeueLight13
        loadingTitleLabel.sizeToFit()
        
        loadingTitleView.addSubview(loadingTitleIconImageView)
        loadingTitleView.addSubview(loadingTitleLabel)
        containerViews.addSubview(loadingTitleView)
        
        //address
        let loadingAddressView = UIView(frame: CGRect(x: 0, y: viewHeight*2 + 2, width: view.frame.width - 20, height: 44))
        loadingAddressView.backgroundColor = UIColor.whiteColor()
        
        let loadingAddressIconImageView = UIImageView(frame: CGRect(x: labelMargin, y: loadingAddressView.frame.height/2 - iconHeight/2 - 2, width: iconHeight, height: iconHeight))
        loadingAddressIconImageView.image = UIImage(named: "home")
        
        let loadingAddressLabel = UILabel(frame: CGRect(x: labelMargin + iconHeight + 3, y: labelMargin, width: loadingAddressView.frame.width - 2*labelMargin - iconHeight - 3, height: loadingAddressView.frame.height - 2*labelMargin))
        loadingAddressLabel.text = newTicket.location?.address
        loadingAddressLabel.numberOfLines = 2
        loadingAddressLabel.font = AppThemes.helveticaNeueLight13
        
        loadingAddressView.addSubview(loadingAddressIconImageView)
        loadingAddressView.addSubview(loadingAddressLabel)
        containerViews.addSubview(loadingAddressView)
        
        //random message label
        let index = Int(arc4random_uniform(UInt32(randomMessages.count)))
        let randomMessageLabel = UILabel(frame: CGRect(x: 0, y: 70, width: view.frame.width - 40, height: 30))
        randomMessageLabel.center.x = transparentView.center.x
        randomMessageLabel.textAlignment = .Center
        randomMessageLabel.font = AppThemes.helveticaNeueLight16
        randomMessageLabel.textColor = UIColor.whiteColor()
        randomMessageLabel.backgroundColor = UIColor.clearColor()
        randomMessageLabel.text = randomMessages[index]
        randomMessageLabel.numberOfLines = 0
        randomMessageLabel.sizeToFit()
        transparentView.addSubview(randomMessageLabel)
        
        //cancel button
        let cancelButton = UIButton(frame: CGRect(x: 0, y: view.frame.height - 30 - 35, width: containerViews.frame.width, height: 35))
        cancelButton.center.x = transparentView.center.x
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.whiteColor().CGColor
        cancelButton.titleLabel?.textColor = UIColor.whiteColor()
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.addTarget(self, action: #selector(cancelTicket), forControlEvents: .TouchUpInside)
        transparentView.addSubview(cancelButton)
        
        //add everything to the transparent view
        transparentView.addSubview(containerViews)
    }
    
    func stopLoadingIndicator() {
        for item in UIApplication.sharedApplication().keyWindow!.subviews
            where item.restorationIdentifier == "TransparentActivityIndicatorViewContainer" {
                UIView.animateWithDuration(0.3, animations: {
                    item.transform = CGAffineTransformMakeScale(0.01, 0.01)
                    }, completion: { finished in
                        item.removeFromSuperview()
                })
        }
    }
    
    func cancelTicket() {
        let alert = UIAlertController(title: "Cancel This Ticket", message: "This process can not be undone. Tap OK to proceed", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { _ in
            
            // Delete this ticket to database and remove it to socket chanel
            let url = "\(API_URL)\(PORT_API)/v1/ticket/\(self.newTicket!.id!)"
            Alamofire.request(.DELETE, url, parameters: nil).responseJSON { response  in
                print(response.result)
                var JSON = self.newTicket.dataJson
                JSON!["status"] = Status.Cancel.rawValue
                SocketManager.sharedInstance.pushCategory(JSON!)
            }
            
            self.stopLoadingIndicator()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func stopLocationManager() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locatewithCoordinate(longitude long: NSNumber, latitude lat: NSNumber){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            let camera = GMSCameraPosition.cameraWithLatitude(lat as Double, longitude: long as Double, zoom: 14)
            self.testView.camera = camera
        }
    }
    
    //MARK: - Actions & Gestures
    
    func pickTime(gestureRecognizer: UIGestureRecognizer) {
        let storyboard = UIStoryboard(name: "MapStoryboard", bundle: nil)
        let calendarPopupViewController = storyboard.instantiateViewControllerWithIdentifier("DateTimePickerViewController") as! DateTimePickerViewController
        
        //nextTime user tap on this, the calendar will appear exactly what user chose before
        //let chosenDateTimeString = newTicket.dateBegin + ", " + newTicket.timeBegin
        calendarPopupViewController.chosenDate = getDateFromString(newTicket.dateBegin, withFormat: DateStringFormat.DD_MMM_YYYY)
        calendarPopupViewController.chosenTime = getDateFromString(newTicket.timeBegin, withFormat: DateStringFormat.HH_mm)
        
        self.presentViewController(calendarPopupViewController, animated: true, completion: nil)
        
        adjustViewsWhenFinishChoosingCategory()
    }
    
    func pickCategory(gestureRecognizer: UIGestureRecognizer) {
        if isShowingCategoryList {
            adjustViewsWhenFinishChoosingCategory()
        } else {
            adjustViewsWhenChoosingCategory()
        }
        isShowingCategoryList = !isShowingCategoryList
    }
    
    func addTicketDetail(gestureRecognizer: UIGestureRecognizer) {
        let storyboard = UIStoryboard(name: "MapStoryboard", bundle: nil)
        let detailPopupViewController = storyboard.instantiateViewControllerWithIdentifier("AddTicketDetailViewController") as! AddTicketDetailViewController
        
        //nextTime user tap on this, the calendar will appear exactly what user chose before
        detailPopupViewController.newTicket = self.newTicket
        
        self.presentViewController(detailPopupViewController, animated: true, completion: nil)
        
        adjustViewsWhenFinishChoosingCategory()
    }
    
    @IBAction func onTableSlideUp(sender: UIButton) {
        
        //if tableview is hidden, slide it up, if it is shown then slide it down
        if !isShowingTableView {
            UIView.animateKeyframesWithDuration(0.6, delay: 0, options: .CalculationModeCubic, animations: {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.33, animations: {
                    self.tableView.transform = CGAffineTransformIdentity
                    self.tableSlideUpView.transform = CGAffineTransformIdentity
                })
                
                //fliping effect for tableSlideUpButton
                UIView.addKeyframeWithRelativeStartTime(0.33, relativeDuration: 0.63, animations: {
                    self.tableSlideUpButton.transform = CGAffineTransformMakeScale(1, 0.1)
                    self.tableSlideUpButton.setImage(UIImage(named: "downFilled"), forState: .Normal)
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
                    self.tableSlideUpView.transform = CGAffineTransformMakeTranslation(0, self.tableViewHeightConstraint.constant)
                })
                
                //fliping effect for tableSlideUpButton
                UIView.addKeyframeWithRelativeStartTime(0.33, relativeDuration: 0.63, animations: {
                    //self.tableSlideUpButton.transform = CGAffineTransformMakeScale(1, 0.1)
                    self.tableSlideUpButton.setImage(UIImage(named: "upFilled"), forState: .Normal)
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
            startLoadingIndicator()
            
            //newTicket?.category = categoryLabel.text!
            newTicket?.user = UserProfile.currentUser
            //newTicket?.location = self.location
            newTicket?.status = Status.Pending
            newTicket?.worker = Worker()
            
            let parameters = parametersTicket(newTicket!)
            
            Alamofire.request(.POST, "\(API_URL)\(PORT_API)/v1/ticket", parameters: parameters).responseJSON { response  in
                
                if response.result.value != nil {
                    let JSON = response.result.value as? [String:AnyObject]
                    let JSONobj = JSON!["data"]! as! [String : AnyObject]
                    self.newTicket = Ticket(data: JSONobj)
                    SocketManager.sharedInstance.pushCategory(JSON!["data"]! as! [String : AnyObject])

                    //self.stopLoadingIndicator()
                } else {
                    //return an error message if cannot send request to server
                    self.stopLoadingIndicator()
                    let alertController = UIAlertController(title: "Error", message: "Cannot push data to server. This could be due to internet connection. Please try again later", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(action)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func onCancelTicket(sender: UIBarButtonItem) {
        
        //if user has already entered some information, show a message warning them. If not, then just dismiss the VC
        if newTicket.title != "" || newTicket.dateBegin != "" || newTicket.timeBegin != "" || newTicket.descriptions != "" || newTicket.category != "" || newTicket.imageOne?.imageUrl != "" {
            
            let alert = UIAlertController(title: "Warning", message: "You will lose all the information entered. Tap OK to go back to the Home Screen", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default) { _ in
                
                //if = nil user hasn'r press findWorker button, so there is no need to delete the ticket from socket channel
                if let id = self.newTicket.id {
                    // Delete this ticket to database and remove it to socket chanel
                    let url = "\(API_URL)\(PORT_API)/v1/ticket/\(id)"
                    Alamofire.request(.DELETE, url, parameters: nil).responseJSON { response  in
                        print(response.result)
                        var JSON = self.newTicket.dataJson
                        JSON!["status"] = Status.Cancel.rawValue
                        SocketManager.sharedInstance.pushCategory(JSON!)
                    }
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

//MARK: - EXTENSION: GMSMapViewDelagate
extension MapViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if marker == userMarker {
            //user doesn't necessarily need a info window
            return nil
        }
        
        let customInfoWindow = NSBundle.mainBundle().loadNibNamed("CustomInfoView", owner: self, options: nil)[0] as! CustomInfoView
        
        if let index = Int(marker.accessibilityLabel!) {
            customInfoWindow.workerNameLabel.text = workerList[index].firstName
            customInfoWindow.hourlyRateLabel.text = workerList[index].price
            
            //if the distance is less than 100 meter than show it in meter, other wise convert to km
            if distanceToTicket[index].distanceInMeters < 1000 {
                let distance = roundToBeutifulNumber(distanceToTicket[index].distanceInMeters, devidedNumber: 10)
                customInfoWindow.distanceFromTicketLabel.text = "\(distance) m"
            } else {
                let distance = distanceToTicket[index].distanceInMeters / 1000
                customInfoWindow.distanceFromTicketLabel.text = String(format: "%.1f km", distance)
            }
        }
        customInfoWindow.layer.borderWidth = 1
        customInfoWindow.layer.borderColor = AppThemes.appColorTheme.CGColor        
        customInfoWindow.pickButton.layer.cornerRadius = 5
        
        return customInfoWindow
    }
    
    func fakeFunction() {
        print("I have picked this worker")
    }
    
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            testView.myLocationEnabled = true
            testView.settings.myLocationButton = true
            startLocationManager()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
        
        //some core location error
        //CLError.LocationUnknown - The location is currently unknown, but Core Location will keep trying.
        //CLError.Denied - The user declined the app to use location services.
        //CLError.Network - There was a network-related error.
        
        if error.code == CLError.LocationUnknown.rawValue {
            //When get this error, you will simply keep trying until you do find a location or receive a more serious error
            return
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            //use this to get the address of the current location and present it on the search bar
            let url = NSURL(string: "\(baseUrl)latlng=\(location.coordinate.latitude),\(location.coordinate.longitude)&key=\(apiKey)")
            Alamofire.request(.GET, url!, parameters: nil).responseJSON { response  in
                if response.response != nil {
                    let json = response.result.value as! NSDictionary
                    if let result = json["results"] as? NSArray {
                        if let address = result[0]["address_components"] as? NSArray {
                            let number = address[0]["short_name"] as! String
                            let street = address[1]["short_name"] as! String
                            let city = address[2]["short_name"] as! String
                            let state = address[4]["short_name"] as! String
                            print("\n\(number) \(street), \(city), \(state)")
                            
                            //center camera aroung the user current location fisnish updating user/s current location
                            self.locatewithCoordinate(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude)
                            
                            self.newTicket.location?.address = "\(number) \(street), \(city), \(state)"
                            self.newTicket.location?.latitude = location.coordinate.latitude
                            self.newTicket.location?.longitute = location.coordinate.longitude
                            
                            //present the current address on the search bar
                            self.searchController!.searchBar.text = self.newTicket.location?.address
                            
                            let position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                            self.userMarker = GMSMarker(position: position)
                            self.userMarker.icon = UIImage(named: "marker_small")
                            self.userMarker.map = self.testView
                        }
                    }
                }
            }
        }
        
        stopLocationManager()
    }
}

//MARK: - EXTENSION: Auto Complete Delegate
extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        testView.clear() //clear all previous marker before adding new marker
        
//        //re put the marker for the worker list after ch
//        for worker in workerList {
//            getMarkerForWorker(worker)
//        }
        searchController?.active = false
        
        locatewithCoordinate(longitude: place.coordinate.longitude, latitude: place.coordinate.latitude)
        self.searchController?.searchBar.text = place.formattedAddress
        
        //add marker
        let position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
        userMarker = GMSMarker(position: position)
        userMarker.icon = UIImage(named: "marker_small")
        userMarker.map = testView
        
        //assign the ticket location to the address found
        newTicket.location?.address = place.formattedAddress
        newTicket.location?.latitude = place.coordinate.latitude
        newTicket.location?.longitute = place.coordinate.longitude
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
        newTicket.category = TicketCategory.categoryNames[currentCategoryIndex]
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

// MARK: - EXTENSION: TableView data source and delegate
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