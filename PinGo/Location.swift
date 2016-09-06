//
//  Location.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class Location: NSObject {
    var address: String?
    var city: String?
    var longitute: NSNumber?
    var latitude: NSNumber?
    override init() {
        address = ""
        city = ""
        longitute = 0
        latitude = 0
    }
    
    init(data: [String : AnyObject]){
        address = data["address"] as? String
        city = data["city"] as? String
        let strLong = data["longtitude"] as? String
        let strLati = data["latitude"] as? String
        if  strLong != "" {
            longitute = HandleUtil.castStringToNSNumber(strLong!)
        } else {
            longitute = 0
        }
        
   
        if strLati != "" {
            latitude = HandleUtil.castStringToNSNumber(strLati!)
        } else {
            latitude = 0
        }
        
    }
    
    func convertToCllLocation() ->CLLocation {
        let lat = self.latitude as! Double
        let long = self.longitute as! Double
        let newLocation = CLLocation(latitude: lat, longitude: long)
        return newLocation

    }
}


