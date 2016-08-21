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
import AFNetworking
import Alamofire
import CoreLocation

class WorkerMapViewController: UIViewController, GMSMapViewDelegate {
    
    @IBAction func test(sender: AnyObject) {
        

        if let locationLog = userLocation.longitute, locationLat = userLocation.latitude, workerloclog = workerlocation.longitute, workerloclat = workerlocation.latitude{
        var urlString = "http://maps.google.com/maps?"
            urlString += "saddr=\(workerloclat),\(workerloclog)"
            urlString += "&daddr=\(locationLat),\(locationLog)"
             print(urlString)
            if let url = NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        
               {
                UIApplication.sharedApplication().openURL(url)
                }
            }
        }
//

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
    var workerlocation = Location()
    var ticket: Ticket?
    var placesClient = GMSPlacesClient()
    
    let baseUrl = "https://maps.googleapis.com/maps/api/directions/json?"
    let distanceMatrixAPI = "AIzaSyCX01Gi9BrDqyLZ7loChcpIotkuhOr-V54"
    let mapDirectionAPI = "AIzaSyBA6WMj7LYhCNyj3ydOyfN0rogeB80UzCo"
    
    var directionShow = false
    
    var userLocation = Location()
    
    var destLocationArray = [Location]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        userLocation.longitute! = -121.406165
        userLocation.latitude! = 37.785771

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        
        currentLocation()

        placesClient = GMSPlacesClient.sharedClient()
//
////        if !directionShow {
//            getDirection(self.workerlocation!.latitude! as Double, lng: self.workerlocation!.longitute! as Double)
//            //            showDirection()
//            //
//            //            directionShow = true
////        }
    }
    

    func currentLocation(){
        
        placesClient.currentPlaceWithCallback({ (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                print("errorrrr")
                return
            }
                        
            self.workerlocation.longitute = (self.locationManager.location?.coordinate.longitude)!
            self.workerlocation.latitude = (self.locationManager.location?.coordinate.latitude)!
            
            self.workerlocation.address = placeLikelihoods!.likelihoods[0].place.formattedAddress!

        })
    }
    
}
////
////    /*
////     // MARK: - Navigation
////     
////     // In a storyboard-based application, you will often want to do a little preparation before navigation
////     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
////     // Get the new view controller using segue.destinationViewController.
////     // Pass the selected object to the new view controller.
////     }
////     */
////    
//    func locatewithCoordinate (long: NSNumber, Latitude lat: NSNumber, Title title:String ){
//        dispatch_async(dispatch_get_main_queue()) { () -> Void in
//            
//            let camera = GMSCameraPosition.cameraWithLatitude(lat as Double, longitude: long as Double, zoom: 16)
//            self.mapView.camera = camera
//            
////            let position = CLLocationCoordinate2DMake(lat as Double, long as Double)
////            self.userMarker = GMSMarker(position: position)
////            //            self.userMarker!.snippet = "\(self.address)"
////            //            self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
////            self.userMarker!.tracksInfoWindowChanges = true
////            self.userMarker!.map = self.mapView
////            self.mapView.selectedMarker = self.userMarker
////            self.userMarker!.icon = UIImage(named:"Pingo")
//            
//            //            let imgView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
//            //            imgView.image = UIImage(named: "Pingo")!
//            //            self.userMarker!.iconView = imgView
//            
//        }
////    }
////    
////    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
////        if !didFindMyLocation {
////            let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
////            mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 13.0)
////            mapView.settings.myLocationButton = true
////            
////            didFindMyLocation = true
////        }
////        
////    }
////    
////    
////}
////
////extension WorkerMapViewController {
////    
////    
////    func getDirection(lat: Double, lng: Double) {
////        if let longitude = userLocation.longitute, let latitude = userLocation.latitude {
////            let surl = String(format: "\(baseUrl)origins=\(lat),\(lng)&destination=\(latitude),\(longitude)&key=\(mapDirectionAPI)")
////            let url = NSURL(string: surl)
////            let request = NSURLRequest(URL: url!)
////            
////            print(surl)
////            
////            
////            do {
////                let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
////                
////                let jsons = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary
////                
////                if let json = jsons {
////                    let stepArray = json.valueForKeyPath("routes.legs.steps") as! NSArray
////                    let array = stepArray[0][0] as! [NSDictionary]
////                    
////                    // Add the 1st location (my location)
////                    destLocationArray.append(workerlocation!)
////                    for step in array {
////                        let desLat = step.valueForKeyPath("end_location.lat") as! Double
////                        let desLng = step.valueForKeyPath("end_location.lng") as! Double
////                        let location = Location()
////                        location.latitude = desLat
////                        location.longitute = desLng
////                        self.destLocationArray.append(location)
////                        //println("lat: \(desLat), lng: \(desLng)")
////                    }
////                }
////                
////            } catch  { }
////        }
////
////    }
////    //        Alamofire.request(.GET, url!, parameters: nil).responseJSON { response  in
////    //            let json = response.result.value as! NSDictionary
////    //            if let result = json["results"] as? NSArray{
////    //
////    //                if let stepArray = json.valueForKeyPath("routes.legs.steps") as? NSArray {
////    //
////    //                    let array = stepArray[0][0][0] as! [NSDictionary]
////    //
////    //                    // Add the 1st location (my location)
////    //                    self.destLocationArray.append(self.workerlocation!)
////    //                    for step in array {
////    //                        let desLat = step.valueForKeyPath("end_location.lat") as! Double
////    //                        let desLng = step.valueForKeyPath("end_location.lng") as! Double
////    //                        let location = Location()
////    //                        location.latitude = desLat
////    //                        location.longitute = desLng
////    //                        self.destLocationArray.append(location)
////    //                        //println("lat: \(desLat), lng: \(desLng)")
////    //                    }
////    //                }
////    //            }
////    //        }
////    
//////    let url = NSURL(string: "\(baseUrl)latlng=\(position.target.latitude),\(position.target.longitude)&key=\(apiKey)")
//////    Alamofire.request(.GET, url!, parameters: nil).responseJSON { response  in
//////    let json = response.result.value as! NSDictionary
//////    if let result = json["results"] as? NSArray {
//////    self.userMarker?.map = nil
//////    if let address = result[0]["address_components"] as? NSArray {
//////    let number = address[0]["short_name"] as! String
//////    let street = address[1]["short_name"] as! String
//////    let city = address[2]["short_name"] as! String
//////    let state = address[4]["short_name"] as! String
//////    //let zip = address[6]["short_name"] as! String
//////    //print("\n\(number) \(street), \(city), \(state)")
//////    self.location!.address = "\(number) \(street), \(city), \(state)"
//////    //                        self.labelAddress.text = self.address
//////    self.labelAddress.text = self.location!.address
//////    self.userMarker = GMSMarker(position: position.target)
//////    //                        self.userMarker!.title = "Setup Location"
//////    //                            self.userMarker!.snippet = "\(self.address)"
//////    //                        self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
//////    self.userMarker!.icon = UIImage(named: "Pingo")
//////    self.userMarker!.tracksInfoWindowChanges = true
//////    self.userMarker!.map = self.testView
//////    self.testView.selectedMarker = self.userMarker
//////    
//////    }
////    
////    func showDirection() {
////    let marker = GMSMarker()
////    marker.position = CLLocationCoordinate2DMake(workerlocation!.latitude as! Double, workerlocation!.longitute as! Double)
////    marker.title = "My location"
////    marker.icon = UIImage(named: "MyLocation")
////    marker.map = mapView
////    
////    let path = GMSMutablePath()
////    for location in destLocationArray {
////    path.addLatitude(CLLocationDegrees(location.latitude!), longitude: CLLocationDegrees(location.longitute!))
////    }
////    
////    let polyline = GMSPolyline(path: path)
////    polyline.strokeColor = UIColor(red: 213/255, green: 28/255, blue: 24/255, alpha: 1.0)
////    polyline.strokeWidth = 5
////    polyline.map = mapView
////    }
////    
////    }
////    
////    
////    
extension WorkerMapViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapView.myLocationEnabled = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError) {
        print("error")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        
        let location_default = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        //        currentlocation_latitude = location.latitude
        //        currentlocation_long = location.longitude
        workerlocation.latitude = location_default.latitude
        workerlocation.longitute = location_default.longitude
        
        print(location_default)
        print(workerlocation)
        
        locationManager.stopUpdatingLocation()
    }
}