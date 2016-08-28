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
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var labelAddress: UILabel!
    
    @IBOutlet weak var findButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var newTicket: Ticket?
    
    //get location
    var locationManager = CLLocationManager()
    
    //get search results
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController!
    var resultView: UITextView?
    
    var didFindMyLocation = false
    var placesClient = GMSPlacesClient()
//    var currentlocation_long = Double()
//    var currentlocation_latitude = Double()
    var userMarker: GMSMarker?
    var isFirstTimeUseMap = true
    var flagCount = 0
    var location :Location?
    
    var currentCategoryIndex = -1 //store current selected category index, set to -1 to avoid crash no cell has been sellected
    
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
        
        //add the start stage for collection View
        collectionView.transform = CGAffineTransformMakeTranslation(0, view.frame.height)

        locationView.hidden = true
//        locationViewStyle ()
        okButtonStyle()
        
        currentLocation()
        setupSubView()
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
//            if let chosenDate = addDetailViewController.chosenDate {
//                
//            }
        }
    }
    
    //MARK: - Helpers
    func okButtonStyle(){
        self.findButton.backgroundColor = AppThemes.appColorTheme
        self.findButton.layer.masksToBounds = true
//        self.okButton.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.findButton.layer.cornerRadius = findButton.frame.size.width/2
        self.findButton.clipsToBounds = true
    }
    
//    func locationViewStyle (){
////        UINavigationBar.appearance().barTintColor = UIColor.clearColor()
//        locationView.layer.cornerRadius = 0
//        locationView.layer.masksToBounds = true
//        locationView.backgroundColor = UIColor.whiteColor()
//        
//        
//        locationView.layer.shadowOffset = CGSizeMake(0, 3); //default is (0.0, -3.0)
//        locationView.layer.shadowColor = UIColor.blackColor().CGColor//default is black
//        locationView.layer.shadowRadius = 1.0 //default is 3.0
//        locationView.layer.shadowOpacity = 0.5
//        
//        labelAddress.textColor = AppThemes.appColorText
////        locationView.layer.borderColor = UIColor.lightGrayColor().CGColor
////        locationView.layer.borderWidth = 1
//    }
    
    
//    func searchAction(sender: AnyObject) {
//        let autocompleteController = GMSAutocompleteViewController()
//        autocompleteController.delegate = self
//        self.presentViewController(autocompleteController, animated: true, completion: nil)
//    }
    

    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            //if user hasn't find any location, show current location
            let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
            testView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 13.0)
            testView.settings.myLocationButton = true
            
            self.location!.longitute = myLocation.coordinate.longitude
            self.location!.latitude = myLocation.coordinate.latitude
            
            self.locatewithCoordinate((self.location?.longitute)!, Latitude: (self.location?.latitude)!, Title: "current location")
            
            let position = CLLocationCoordinate2DMake(self.location?.longitute as! Double, self.location?.latitude as! Double)
            self.userMarker = GMSMarker(position: position)
            //            self.userMarker!.snippet = "\(self.address)"
            //            self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            self.userMarker!.tracksInfoWindowChanges = true
            self.userMarker!.map = self.testView
            self.testView.selectedMarker = self.userMarker
            self.userMarker!.icon = UIImage(named:"Marker50")
            
//            var imgView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
//            imgView.image = UIImage(named: "Pingo")!
//            self.userMarker!.icon = UIImage(named: "Pingo")!
            
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
        
        detailLabel = UILabel(frame: CGRect(x: labelMargin + iconHeight + 3, y: addDetailView.frame.height/2 - iconHeight/2, width: labelWidth, height: labelHeight))
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
        
        self.presentViewController(detailPopupViewController, animated: true, completion: nil)
        
        adjustViewsWhenFinishChoosingCategory()
    }
    
    //MARK: - Google Map API
    func currentLocation(){
//            self.locatewithCoordinate(self.currentlocation_long, Latitude: self.currentlocation_latitude, Title: "current location")
//            let position = CLLocationCoordinate2DMake(self.currentlocation_latitude, self.currentlocation_long)
            
//            self.labelAddress.text = self.location!.address
            
            self.flagCount = 1
    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        if (userMarker != nil && flagCount > 0) {
            flagCount = 2
            let url = NSURL(string: "\(baseUrl)latlng=\(position.target.latitude),\(position.target.longitude)&key=\(apiKey)")
            Alamofire.request(.GET, url!, parameters: nil).responseJSON { response  in
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
                        self.userMarker!.icon = UIImage(named: "Marker50")
                        self.userMarker!.tracksInfoWindowChanges = true
                        self.userMarker!.map = self.testView
                        self.testView.selectedMarker = self.userMarker
                        
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
            self.userMarker!.icon = UIImage(named: "Marker50")
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

//extension MapViewController {
//    func initSearchAction(){
//        let gesture = UITapGestureRecognizer(target: self, action: #selector(searchAction(_:)))
//        locationView.addGestureRecognizer(gesture)
//        
//    }
//}

//search full screen
//extension MapViewController: GMSAutocompleteViewControllerDelegate {
//    
//    // Handle the user's selection.
//    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
//        print("Place name: ", place.name)
//        print("Place address: ", place.formattedAddress)
//        print("Place attributions: ", place.attributions)
//        
//        locatewithCoordinate(place.coordinate.longitude, Latitude: place.coordinate.latitude, Title: place.formattedAddress!)
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
//        // TODO: handle the error.
//        print("Error: ", error.description)
//    }
//    
//    // User canceled the operation.
//    func wasCancelled(viewController: GMSAutocompleteViewController) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    // Turn the network activity indicator on and off again.
//    func didRequestAutocompletePredictions(viewController: GMSAutocompleteViewController) {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//    }
//    
//    func didUpdateAutocompletePredictions(viewController: GMSAutocompleteViewController) {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//    }
//    
//}

////search bar under navigation
//extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
//    func resultsController(resultsController: GMSAutocompleteResultsViewController!,
//                           didAutocompleteWithPlace place: GMSPlace!) {
//        searchController?.active = false
//        // Do something with the selected place.
//        print("Place name: ", place.name)
//        print("Place address: ", place.formattedAddress)
//        print("Place attributions: ", place.attributions)
//    }
//    
//    func resultsController(resultsController: GMSAutocompleteResultsViewController!,
//                           didFailAutocompleteWithError error: NSError!){
//        // TODO: handle the error.
//        print("Error: ", error.description)
//    }
//    
//    // Turn the network activity indicator on and off again.
//    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController!) {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//    }
//    
//    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController!) {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//    }
//}

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

//MARK: - EXTENSION: UISearchControllerDelegate
extension MapViewController: UISearchControllerDelegate {
    func willPresentSearchController(searchController: UISearchController) {
        adjustViewsWhenFinishChoosingCategory()
    }
}