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


class MapViewController: UIViewController, UISearchDisplayDelegate, GMSMapViewDelegate{
    
    @IBOutlet weak var testView: GMSMapView!
    
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
    var isFirstTimeUseMap: Bool = true
    var flagCount: Int = 0
    var location :Location?
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var labelAddress: UILabel!
    
    @IBOutlet weak var okButton: UIButton!

    
    let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
    let apiKey = "AIzaSyBgEYM4Ho-0gCKypMP5qSfRoGCO1M1livw"
    
//    var address: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        location = Location()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        
        //current locatioN
        currentLocation()
        
        testView.delegate = self

//        locationView.hidden = true
        locationViewStyle ()
        okButtonStyle()
        
        placesClient = GMSPlacesClient.sharedClient()
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        //SEARCH BAR
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        let subViews = UIView(frame: CGRectMake(0, 20, view.frame.width, 45.0))
        
        let searchBar = searchController?.searchBar
        subViews.addSubview(searchBar!)
        self.view.addSubview(subViews)
        searchBar!.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = true
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        let searchTextField = searchBar!.valueForKey("_searchField") as? UITextField
        searchTextField?.backgroundColor = AppThemes.navigationBackgroundColor
        searchTextField?.textColor = UIColor.whiteColor()
        
        searchController?.searchBar.barTintColor = AppThemes.navigationBackgroundColor
        searchController?.searchBar.tintColor = UIColor.whiteColor()
    }
    
    @IBAction func okButtonAction(sender: AnyObject) {
        
        
    }
    override func viewWillAppear(animated: Bool) {
         testView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
//        removeObserver:fromObjectsAtIndexes:forKeyPath:context: 
        testView.removeObserver(self, forKeyPath: "myLocation")
    }
    
    func okButtonStyle(){
        self.okButton.backgroundColor = AppThemes.navigationBackgroundColor
        self.okButton.layer.masksToBounds = true
//        self.okButton.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.okButton.layer.cornerRadius = okButton.frame.size.width/2
        self.okButton.clipsToBounds = true
    }
    
    func locationViewStyle (){
        UINavigationBar.appearance().barTintColor = UIColor.clearColor()
        locationView.layer.cornerRadius = 0
        locationView.layer.masksToBounds = true
        locationView.backgroundColor = AppThemes.navigationBackgroundColor
//        locationView.layer.borderColor = UIColor.lightGrayColor().CGColor
//        locationView.layer.borderWidth = 1
    }
    
//    func searchAction(sender: AnyObject) {
//        let autocompleteController = GMSAutocompleteViewController()
//        autocompleteController.delegate = self
//        self.presentViewController(autocompleteController, animated: true, completion: nil)
//    }
    

    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
            testView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 13.0)
            testView.settings.myLocationButton = true
            
            didFindMyLocation = true
        }
        
    }
    
    
    //---------------Google Map AP
    
    func currentLocation(){
        
        placesClient.currentPlaceWithCallback({ (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                return
            }
            
            self.location?.longitute = (self.locationManager.location?.coordinate.longitude)!
            self.location?.latitude = (self.locationManager.location?.coordinate.latitude)!
            self.location?.address = placeLikelihoods!.likelihoods[0].place.formattedAddress!
            
//            self.currentlocation_long = (self.locationManager.location?.coordinate.longitude)!
//            self.currentlocation_latitude = (self.locationManager.location?.coordinate.latitude)!
//            self.address = placeLikelihoods!.likelihoods[0].place.formattedAddress!
//            
            // Set up Marker:
            
            self.locatewithCoordinate((self.location?.longitute)!, Latitude: (self.location?.latitude)!, Title: "current location")
            let position = CLLocationCoordinate2DMake(self.location?.longitute as! Double, self.location?.latitude as! Double)

//            self.locatewithCoordinate(self.currentlocation_long, Latitude: self.currentlocation_latitude, Title: "current location")
//            let position = CLLocationCoordinate2DMake(self.currentlocation_latitude, self.currentlocation_long)
            self.userMarker = GMSMarker(position: position)
//            self.userMarker!.snippet = "\(self.address)"
//            self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            self.userMarker!.tracksInfoWindowChanges = true
            self.userMarker!.map = self.testView
            self.testView.selectedMarker = self.userMarker
            
            self.labelAddress.text = self.location!.address
            
            self.flagCount = 0
            
        })
        
        
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
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        if (userMarker != nil && flagCount > 1) {
            print("hei")
            flagCount = 1
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
                        let zip = address[6]["short_name"] as! String
                        print("\n\(number) \(street), \(city), \(state) \(zip)")
                        self.location!.address = "\(number) \(street), \(city), \(state) \(zip)"
//                        self.labelAddress.text = self.address
                        self.labelAddress.text = self.location!.address
                        self.userMarker = GMSMarker(position: position.target)
//                        self.userMarker!.title = "Setup Location"
//                            self.userMarker!.snippet = "\(self.address)"
//                        self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
                        self.userMarker!.tracksInfoWindowChanges = true
                        self.userMarker!.map = self.testView
                        self.testView.selectedMarker = self.userMarker
                        
                    }
                }
            }
            
        }
        
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        if (userMarker != nil) {
            self.userMarker!.map = nil
            self.userMarker = GMSMarker(position: position.target)
//            self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            self.userMarker!.tracksInfoWindowChanges = true
            self.userMarker!.map = self.testView
            self.testView.selectedMarker = nil
//            self.userMarker?.snippet = "\(self.address)"
            flagCount += 1
            self.labelAddress.text = self.location!.address
            UINavigationBar.appearance().barTintColor = UIColor.clearColor()
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
            testView.myLocationEnabled = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError) {
        print("error")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var userLocation = locations[0]
        
        let location_default = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
//        currentlocation_latitude = location.latitude
//        currentlocation_long = location.longitude
        location!.latitude = location_default.latitude
        location!.longitute = location_default.longitude
        
        print(location_default)
        print(location)
        
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
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        
        locatewithCoordinate(place.coordinate.longitude, Latitude: place.coordinate.latitude, Title: place.formattedAddress!)
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: NSError){
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}