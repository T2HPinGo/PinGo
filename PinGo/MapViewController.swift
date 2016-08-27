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
    
    @IBOutlet weak var okButton: UIButton!
    //get location
    var locationManager = CLLocationManager()
    
    //get search results
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    var didFindMyLocation = false
    var placesClient = GMSPlacesClient()
//    var currentlocation_long = Double()
//    var currentlocation_latitude = Double()
    var userMarker: GMSMarker?
    var isFirstTimeUseMap = true
    var flagCount = 0
    var location :Location?
    
    let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
    let apiKey = "AIzaSyBgEYM4Ho-0gCKypMP5qSfRoGCO1M1livw"
    
//    var address: String = ""
    
    //MARK: - Load Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true

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
    
    //MARK: - Actions
    @IBAction func okButtonAction(sender: AnyObject) {

    }
    
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
    
    //MARK: - Navigations
    @IBAction func unwindFromDateTimePicker(segue: UIStoryboardSegue) {
        
    }
    
    //MARK: - Helpers & Gestures
    func okButtonStyle(){
        self.okButton.backgroundColor = AppThemes.appColorTheme
        self.okButton.layer.masksToBounds = true
//        self.okButton.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.okButton.layer.cornerRadius = okButton.frame.size.width/2
        self.okButton.clipsToBounds = true
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
            
//            
//            var imgView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
//            imgView.image = UIImage(named: "Pingo")!
//            self.userMarker!.icon = UIImage(named: "Pingo")!
            
            didFindMyLocation = true
        }
        
    }
    
    func setupSubView(){
        //        self.navigationController?.setNavigationBarHidden(true, animated: true)
        let subViews = UIView(frame: CGRectMake(10, 75, view.bounds.width - 20, 134.0))
        //subViews.layer.shadowOffset = CGSizeMake(0, 3); //default is (0.0, -3.0)
        //subViews.layer.shadowColor = UIColor.blackColor().CGColor//default is black
        //subViews.layer.shadowRadius = 1.0 //default is 3.0
        //subViews.layer.shadowOpacity = 0.5 //default is 0.0
        
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
        
        
        let spaceBetweenViews: CGFloat = 1.0
        let viewHeight: CGFloat = 44
        let viewWidthSmall: CGFloat = (view.frame.width - 20 - 2*spaceBetweenViews) / 3
        let labelMargin: CGFloat = 3
        let labelHeight:CGFloat = 20
        let labelWidth: CGFloat = viewWidthSmall - 2*labelMargin
        
        //Category
        let categoryView = UIView(frame: CGRect(x: 0, y: 45, width: viewWidthSmall, height: viewHeight))
        let categoryLabel = UILabel(frame: CGRect(x: labelMargin, y: labelMargin, width: labelWidth, height: labelHeight))
        categoryLabel.text = "Electricity"
        categoryLabel.font = AppThemes.helveticaNeueLight13
        categoryView.addSubview(categoryLabel)
        categoryView.backgroundColor = UIColor.yellowColor()
        subViews.addSubview(categoryView)
        
        
        //Date & Time picker
        let dateView = UIView(frame: CGRect(x: viewWidthSmall + spaceBetweenViews, y: 45 , width: viewWidthSmall, height: viewHeight))
        dateView.backgroundColor = UIColor.greenColor()
        let pickTimeGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickTime(_:)))
        subViews.addGestureRecognizer(pickTimeGestureRecognizer)
        let dateLabel = UILabel(frame: CGRect(x: labelMargin, y: labelMargin, width: labelWidth, height: labelHeight))
        dateLabel.text = "28 JUL 2016"
        dateLabel.font = AppThemes.helveticaNeueLight13
        dateLabel.sizeToFit()
        
        let timeLabel = UILabel(frame: CGRect(x: labelMargin, y: viewHeight - labelMargin - labelHeight, width: labelWidth, height: labelHeight))
        timeLabel.text = "19:00"
        timeLabel.font = AppThemes.helveticaNeueLight13
        dateView.addSubview(dateLabel)
        dateView.addSubview(timeLabel)
        subViews.addSubview(dateView)
        
        let paymentView = UIView(frame: CGRect(x: 2*viewWidthSmall + 2*spaceBetweenViews, y: 45, width: viewWidthSmall, height: viewHeight))
        paymentView.backgroundColor = UIColor.cyanColor()
        let paymentLabel = UILabel(frame: CGRect(x: labelMargin, y: labelMargin, width: labelWidth, height: labelHeight))
        paymentLabel.text = "CASH"
        paymentLabel.font = AppThemes.helveticaNeueLight13
        paymentLabel.sizeToFit()
        paymentView.addSubview(paymentLabel)
        subViews.addSubview(paymentView)
        
        let addDetailView = UIView(frame: CGRect(x: 0, y: 44 + 1 + 44 + 1, width: view.frame.width - 20, height: viewHeight))
        addDetailView.backgroundColor = UIColor.blueColor()
        subViews.addSubview(addDetailView)
        
        self.view.addSubview(subViews)
    }
    
    func pickTime(gestureRecognizer: UIGestureRecognizer) {
        
        print("helooooooo")
        let storyboard = UIStoryboard(name: "MapStoryboard", bundle: nil)
        let calendarPopupViewController = storyboard.instantiateViewControllerWithIdentifier("DateTimePickerViewController") as! DateTimePickerViewController
        
        //self.navigationController?.pushViewController(calendarPopupViewController, animated: true)
        self.presentViewController(calendarPopupViewController, animated: true, completion: nil)//pushViewController(mapViewController, animated: true)
    }
    
    //---------------Google Map AP
    
    func currentLocation(){
//            self.locatewithCoordinate(self.currentlocation_long, Latitude: self.currentlocation_latitude, Title: "current location")
//            let position = CLLocationCoordinate2DMake(self.currentlocation_latitude, self.currentlocation_long)
            
//            self.labelAddress.text = self.location!.address
            
            self.flagCount = 1
    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        if (userMarker != nil && flagCount > 0) {
            //print("hei")
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