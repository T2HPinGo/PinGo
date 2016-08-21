//
//  WorkerMapViewController.swift
//  PinGo
//
//  Created by Haena Kim on 8/21/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class WorkerMapViewController: UIViewController, GMSMapViewDelegate {
    
    //    PUT THIS IN WORKER TICKET VIEW IN ACTION
    
    //    IBAction func showDirection(sender: AnyObject) {
    //
    //    var urlString = "http://maps.google.com/maps?"
    //    urlString += "saddr = \(currentlocation.latitude), \(currentlocation.longitude)"
    //    urlString += "&daddr = \(ticket.location.latitude), \(ticket.location.longitude)"
    //     print(urlString)
    //    if let url = NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
    //
    //    {
    //        UIApplication.sharedApplication().openURL(url)
    //        }
    //
    //}
    
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var userMarker: GMSMarker?
    var workerMarker: GMSMarker?
    var workerlocation: Location?
    var ticket: Ticket?
    var placesClient = GMSPlacesClient()
    
    let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
    let apiKey = "AIzaSyBgEYM4Ho-0gCKypMP5qSfRoGCO1M1livw"
    
    var directionShow = false
    
    var userLocation = Location()
    
    var destLocationArray = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userLocation.longitute = -122.406165
        userLocation.latitude = 37.785771
        
        workerlocation = Location()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        currentLocation()
    }
    
    
    
    func currentLocation(){
        
        
        placesClient.currentPlaceWithCallback({ (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                return
            }
            
            self.workerlocation?.longitute = (self.locationManager.location?.coordinate.longitude)!
            self.workerlocation?.latitude = (self.locationManager.location?.coordinate.latitude)!
            self.workerlocation?.address = placeLikelihoods!.likelihoods[0].place.formattedAddress!
            
            self.locatewithCoordinate((self.workerlocation?.longitute)!, Latitude: (self.workerlocation?.latitude)!, Title: "worker location")
            let position = CLLocationCoordinate2DMake(self.workerlocation?.longitute as! Double, self.workerlocation?.latitude as! Double)
            self.userMarker = GMSMarker(position: position)
            //            self.userMarker!.snippet = "\(self.address)"
            //            self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            self.userMarker!.tracksInfoWindowChanges = true
            self.userMarker!.map = self.mapView
            self.mapView.selectedMarker = self.userMarker
            //            self.userMarker!.icon = UIImage(named:"Pingo")
            
            let imgView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
            imgView.image = UIImage(named: "Pingo")!
            self.userMarker!.iconView = imgView
            
        })
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func locatewithCoordinate (long: NSNumber, Latitude lat: NSNumber, Title title:String ){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            let camera = GMSCameraPosition.cameraWithLatitude(lat as Double, longitude: long as Double, zoom: 16)
            self.mapView.camera = camera
            
        }
    }
    
    
    
}

extension WorkerMapViewController {
    
    func mapLoad() {
        let camera = GMSCameraPosition.cameraWithLatitude(workerlocation!.latitude! as Double, longitude: workerlocation!.longitute! as Double, zoom: 15)
        mapView.camera = camera
        mapView.myLocationEnabled = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(workerlocation!.latitude! as Double, workerlocation!.longitute! as Double)
        marker.title = "worker"
        marker.map = mapView
    }
    
    
    // MARK: Get direction
    
    func onGetDirection(sender:UITapGestureRecognizer) {
        if !directionShow {
            getDirection(workerlocation!.latitude! as Double, lng: workerlocation!.longitute! as Double)
            showDirection()
            
            directionShow = true
        }
    }
    
    func getDirection(lat: Double, lng: Double) {
        let sUrl = String(format: "http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&mode=driving", arguments: [userLocation.latitude!, userLocation.longitute!, lat, lng])
        
        let url = NSURL(string: sUrl)
        
        let request = NSURLRequest(URL: url!)
        
        do {
            
            //            let data = try NSURLSession.dataTaskWithRequest(request)
            let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
            
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary
            
            if let json = json {
                let stepArray = json.valueForKeyPath("routes.legs.steps") as! NSArray
                let array = stepArray[0][0] as! [NSDictionary]
                
                // Add the 1st location (my location)
                destLocationArray.append(workerlocation!)
                for step in array {
                    let desLat = step.valueForKeyPath("end_location.lat") as! Double
                    let desLng = step.valueForKeyPath("end_location.lng") as! Double
                    let appendlocation = Location()
                    appendlocation.latitude = desLat
                    appendlocation.longitute = desLng
                    self.destLocationArray.append(appendlocation)
                    
                }
            }
            
        } catch  { }
    }
    
    func showDirection() {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(workerlocation!.latitude as! Double, workerlocation!.longitute as! Double)
        marker.title = "My location"
        marker.icon = UIImage(named: "MyLocation")
        marker.map = mapView
        
        let path = GMSMutablePath()
        for location in destLocationArray {
            path.addLatitude(CLLocationDegrees(location.latitude!), longitude: CLLocationDegrees(location.longitute!))
        }
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor(red: 213/255, green: 28/255, blue: 24/255, alpha: 1.0)
        polyline.strokeWidth = 5
        polyline.map = mapView
    }
    
}



extension WorkerMapViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapView.myLocationEnabled = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        
        let location_default = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        //        currentlocation_latitude = location.latitude
        //        currentlocation_long = location.longitude
        workerlocation!.latitude = location_default.latitude
        workerlocation!.longitute = location_default.longitude
        
        print(location_default)
        print(workerlocation)
        
        locationManager.stopUpdatingLocation()
    }
}

