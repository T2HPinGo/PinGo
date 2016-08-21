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
    var location: Location?
    var ticket: Ticket?
    var placesClient = GMSPlacesClient()
    
    let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
    let apiKey = "AIzaSyBgEYM4Ho-0gCKypMP5qSfRoGCO1M1livw"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        location = Location()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        /
    }

    

    func currentLocation(){
        
        
        placesClient.currentPlaceWithCallback({ (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                return
            }
            
            self.location?.longitute = (self.locationManager.location?.coordinate.longitude)!
            self.location?.latitude = (self.locationManager.location?.coordinate.latitude)!
            self.location?.address = placeLikelihoods!.likelihoods[0].place.formattedAddress!
            
            self.locatewithCoordinate((self.location?.longitute)!, Latitude: (self.location?.latitude)!, Title: "current location")
            let position = CLLocationCoordinate2DMake(self.location?.longitute as! Double, self.location?.latitude as! Double)
            self.userMarker = GMSMarker(position: position)
            //            self.userMarker!.snippet = "\(self.address)"
            //            self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            self.userMarker!.tracksInfoWindowChanges = true
            self.userMarker!.map = self.testView
            self.testView.selectedMarker = self.userMarker
            //            self.userMarker!.icon = UIImage(named:"Pingo")
            
            var imgView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
            imgView.image = UIImage(named: "Pingo")!
            self.userMarker!.iconView = imgView
            
            self.labelAddress.text = self.location!.address
            
            self.flagCount = 0
            
        })

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WorkerMapViewController {
    
    func mapLoad() {
        let camera = GMSCameraPosition.cameraWithLatitude(currentlocation!.latitude!, longitude: currentlocation.longitude!, zoom: 15)
        mapView.camera = camera
        mapView.myLocationEnabled = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(selectedBusiness.latitude!, selectedBusiness.longitude!)
        marker.title = selectedBusiness.name!
        marker.map = mapView
    }
    
    func configDirectionView() {
        getDirectionView.layer.cornerRadius = 5
        getDirectionView.layer.borderWidth = 1
        getDirectionView.layer.borderColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0).CGColor
        
        let onGetDirection = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.onGetDirection(_:)))
        getDirectionView.addGestureRecognizer(onGetDirection)
    }
    
    // MARK: Get direction
    
    func onGetDirection(sender:UITapGestureRecognizer) {
        if !showedDirection {
            getDirection(selectedBusiness.latitude!, lng: selectedBusiness.longitude!)
            showDirection()
            
            showedDirection = true
        }
    }
    
    func getDirection(lat: Double, lng: Double) {
        let sUrl = String(format: "http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&mode=driving", arguments: [myLocation.latitude, myLocation.longitude, lat, lng])
        
        let url = NSURL(string: sUrl)
        
        let request = NSURLRequest(URL: url!)
        
        do {
            let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
            
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary
            
            if let json = json {
                let stepArray = json.valueForKeyPath("routes.legs.steps") as! NSArray
                let array = stepArray[0][0] as! [NSDictionary]
                
                // Add the 1st location (my location)
                destLocationArray.append(myLocation)
                for step in array {
                    let desLat = step.valueForKeyPath("end_location.lat") as! Double
                    let desLng = step.valueForKeyPath("end_location.lng") as! Double
                    self.destLocationArray.append(Location(lat: desLat, lng: desLng))
                    //println("lat: \(desLat), lng: \(desLng)")
                }
            }
            
        } catch  { }
    }
    
    func showDirection() {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(myLocation.latitude, myLocation.longitude)
        marker.title = "My location"
        marker.icon = UIImage(named: "MyLocation")
        marker.map = mapView
        
        let path = GMSMutablePath()
        for location in destLocationArray {
            path.addLatitude(CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude))
        }
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor(red: 213/255, green: 28/255, blue: 24/255, alpha: 1.0)
        polyline.strokeWidth = 5
        polyline.map = mapView
    }
    
}

}

extension WorkerMapViewController: CLLocationManagerDelegate {
    
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

