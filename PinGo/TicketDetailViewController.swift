//
//  TicketDetailViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/21/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class TicketDetailViewController: UIViewController {
    
    @IBOutlet weak var categoryIconView: UIView!
    @IBOutlet weak var categoryIconImageView: UIImageView!
    
    @IBOutlet weak var ticketTitleLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var bidButton: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    var marker = GMSMarker()
    let locationManager = CLLocationManager()
    
    var colorTheme: UIColor!
    
    var ticket: Ticket!
    
    var imageUrls: [String]! //store image urls

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        imageUrls = ticket.getImagesArray()
        configureLabels()
        setupAppearance()
        
        let latitude = ticket.location?.latitude as! Double
        let longitude = ticket.location?.longitute as! Double
      
        let camera = GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom: 14.0)
        let position = CLLocationCoordinate2DMake(latitude, longitude)
        self.marker = GMSMarker(position: position)
        //            self.userMarker!.snippet = "\(self.address)"
        //            self.userMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
        self.marker.tracksInfoWindowChanges = true
        self.marker.map = self.mapView
        self.mapView.camera = camera
        self.mapView.selectedMarker = self.marker
        self.marker.icon = UIImage(named:"Pingo")
        
        
    }
    
    func setupAppearance() {
        bidButton.layer.cornerRadius = 5
        bidButton.layer.borderColor = colorTheme.CGColor
        bidButton.layer.borderWidth = 1.0
        bidButton.tintColor = colorTheme
        
        categoryIconView.layer.cornerRadius = categoryIconView.frame.width / 2
        categoryIconView.backgroundColor = colorTheme
    }
    
    func configureLabels() {
        ticketTitleLabel.text = ticket.title
        descriptionLabel.text = ticket.descriptions != "" ? ticket.descriptions : "No description"

    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ViewImageSegue" {
            if let indexPaths = collectionView.indexPathsForSelectedItems() {
                let pageViewController = segue.destinationViewController as! PhotoSlidePageViewController
                pageViewController.imageUrls = self.imageUrls
                pageViewController.index = indexPaths.first?.item
            }
        }
    }
    
    @IBAction func unwindFromPhotoView(sender: UIStoryboardSegue) {
        
    }
    
}

extension TicketDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TicketImageCell", forIndexPath: indexPath) as! TicketImageCell
        cell.imageUrl = imageUrls[indexPath.row]
        return cell
    }
    
    //custommize size for item
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        //if the width is greater than that of ip6
        let width = (view.bounds.width - 10*4) / 3
        let height = width
        
        return CGSizeMake(width, height)
    }
    
    //layout for cell
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}




//MARK: - ///////////EXTENSION: CLLocationManagerDelegate
extension TicketDetailViewController: CLLocationManagerDelegate{
    //when user grants or revokes location permission
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse{
            locationManager.startUpdatingLocation()
            
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    //when location manager receives new location data
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            //update the map camera to center around the user's current location
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
}


