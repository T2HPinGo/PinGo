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


class MapViewController: UIViewController, UISearchDisplayDelegate, GMSMapViewDelegate{
    
    @IBOutlet weak var testView: GMSMapView!
    
    @IBOutlet weak var okButton: UIButton!
    
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var placesClient = GMSPlacesClient()
    var currentlocation_long = Double()
    var currentlocation_latitude = Double()
    var userMarker: GMSMarker?
    var isFirstTimeUseMap: Bool = true
    var flagCount: Int = 0
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var labelAddress: UILabel!
    
    
    let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
    let apiKey = "AIzaSyBgEYM4Ho-0gCKypMP5qSfRoGCO1M1livw"
    
    var address: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //current locatioN
        currentLocation()
        testView.delegate = self
        //        viewMap()
        
        testView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        
        //        searchBar()
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(MapViewController.next))
        
        
        self.okButton.layer.cornerRadius = self.okButton.frame.size.width/2
        self.okButton.clipsToBounds = true
        self.okButton.backgroundColor = AppThemes.cellColors[4]
        
        self.okButton.layer.borderWidth = 0.2
        self.okButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        placesClient = GMSPlacesClient.sharedClient()
        initSearchAction()
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        testView.removeObserver(self, forKeyPath: "myLocation")
    }
    
    
    
    func searchAction(sender: AnyObject) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.presentViewController(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func okAction(sender: AnyObject) {
        performSegueWithIdentifier("mapviewchange", sender: self)
    }
    
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
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if locationManager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization)){
            locationManager.requestWhenInUseAuthorization()
        }
        else{
            locationManager.startUpdatingLocation()
        }
        
        placesClient.currentPlaceWithCallback({ (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                return
            }
            
            self.currentlocation_long = (self.locationManager.location?.coordinate.longitude)!
            self.currentlocation_latitude = (self.locationManager.location?.coordinate.latitude)!
            self.address = placeLikelihoods!.likelihoods[0].place.formattedAddress!
            
            // Set up Marker:
            self.locatewithCoordinate(self.currentlocation_long, Latitude: self.currentlocation_latitude, Title: "current location")
            let position = CLLocationCoordinate2DMake(self.currentlocation_latitude, self.currentlocation_long)
            self.userMarker = GMSMarker(position: position)
            self.userMarker!.title = "Setup Location"
            self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            self.userMarker!.tracksInfoWindowChanges = true
            self.userMarker!.map = self.testView
            self.testView.selectedMarker = self.userMarker
            
            self.labelAddress.text = self.address
            
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
                    self.userMarker!.map = nil
                    if let address = result[0]["address_components"] as? NSArray {
                        let number = address[0]["short_name"] as! String
                        let street = address[1]["short_name"] as! String
                        let city = address[2]["short_name"] as! String
                        let state = address[4]["short_name"] as! String
                        let zip = address[6]["short_name"] as! String
                        print("\n\(number) \(street), \(city), \(state) \(zip)")
                        self.address = "\(number) \(street), \(city), \(state) \(zip)"
                        self.labelAddress.text = self.address
                        self.userMarker = GMSMarker(position: position.target)
                        self.userMarker!.title = "Setup Location"
                        self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
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
            self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            self.userMarker!.tracksInfoWindowChanges = true
            self.userMarker!.map = self.testView
            self.testView.selectedMarker = nil
            flagCount += 1
            self.labelAddress.text = self.address
        }
        
        
        
    }
    
    func locatewithCoordinate (long: Double, Latitude lat: Double, Title title:String ){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            let camera = GMSCameraPosition.cameraWithLatitude(lat, longitude: long, zoom: 16)
            self.testView.camera = camera
        }
    }
}


// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            testView.myLocationEnabled = true
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError) {
        print("error")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var userLocation = locations[0]
        
        let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        currentlocation_latitude = location.latitude
        currentlocation_long = location.longitude
        
        print(location)
        
        locationManager.stopUpdatingLocation()
    }
}

extension MapViewController {
    func initSearchAction(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(searchAction(_:)))
        locationView.addGestureRecognizer(gesture)
        
    }
}
extension MapViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        
        locatewithCoordinate(place.coordinate.longitude, Latitude: place.coordinate.latitude, Title: place.formattedAddress!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
}