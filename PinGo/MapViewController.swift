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

class MapViewController: UIViewController, UISearchDisplayDelegate{
    
    @IBOutlet weak var testView: GMSMapView!
    
    @IBOutlet weak var okButton: UIButton!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var placesClient = GMSPlacesClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //current locatioN
        currentLocation()
        
        //        viewMap()
        
        testView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        
        searchBar()
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(MapViewController.next))
        
        
        self.okButton.layer.cornerRadius = self.okButton.frame.size.width/2
        self.okButton.clipsToBounds = true
        self.okButton.backgroundColor = AppThemes.cellColors[4]
        
        self.okButton.layer.borderWidth = 0.2
        self.okButton.layer.borderColor = UIColor.whiteColor().CGColor
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
    
    
    //    func next (){
    //        performSegueWithIdentifier("mapviewchange", sender: self)
    //    }
    
    //    override func viewDidAppear(animated: Bool) {
    ////        self.testView = GMSMapView(frame: view.frame)
    ////        self.testview.addSubview(self.mapView)
    //    }
    
    //    func viewMap() {
    //        let camera = GMSCameraPosition.cameraWithLatitude(37.7749, longitude: -122.4194, zoom: 12)
    //        mapView = GMSMapView.mapWithFrame(.zero, camera: camera)
    //        view = mapView
    //
    //        let currentLocation = CLLocationCoordinate2DMake(37.7749, -122.4194)
    //        let marker = GMSMarker(position: currentLocation)
    //        marker.title = "home"
    //        marker.snippet = "need help on .."
    //        marker.map = mapView
    //    }
    
    func currentLocation(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        placesClient.currentPlaceWithCallback({ (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                return
            }
            
            if let placeLikelihoods = placeLikelihoods {
                for likelihood in placeLikelihoods.likelihoods {
                    let place = likelihood.place
//                    print("Current Place name \(place.name) at likelihood \(likelihood.likelihood)")
//                    print("Current Place address \(place.formattedAddress)")
//                    print("Current Place attributions \(place.attributions)")
//                    print("Current PlaceID \(place.placeID)")
                }
            }
        })
        
    }
    
    
    func searchBar(){
        
        //SearchBar: Add an autocomplete UI control
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        self.navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        
        self.navigationController!.navigationBar.translucent = false
        searchController!.hidesNavigationBarDuringPresentation = false
        
        // This makes the view area include the nav bar even though it is opaque.
        // Adjust the view placement down.
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = UIRectEdge.Top
        
    }
    
    
    func locatewithCoordinate (long: Double, Latitude lat: Double, Title title:String ){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let position = CLLocationCoordinate2DMake(lat, long)
            let marker = GMSMarker(position: position)
            
            let camera = GMSCameraPosition.cameraWithLatitude(lat, longitude: long, zoom: 16)
            self.testView.camera = camera
            
            marker.title = "Service name"
            marker.snippet = "Address: \(title)"
            marker.map = self.testView
            marker.tracksInfoWindowChanges = false
            
        }
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

//SearchBar: Add an autocomplete UI control

extension MapViewController:GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        searchController?.active = false
        // Do something with the selected place.
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress!)
        print("Place attributions: ", place.attributions)
        print("Place longitude: ", place.coordinate.longitude)
        print("Place latitude: ", place.coordinate.latitude)
        
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
    
    locationManager.stopUpdatingLocation()
    
    let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
    
    print(location)
    }
}