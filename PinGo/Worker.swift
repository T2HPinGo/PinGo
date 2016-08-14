//
//  Worker.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class Worker: UserProfile {
    
    var averageRating: Double?
    
    override init() {
        super.init()
        averageRating = 0
    }
    override init(data: [String : AnyObject]) {
        super.init(data: data)
        averageRating = data["averageRating"] as? Double
//        isWorker = true
    }
    
    var currentLocation: Location?
    var rating: Double?
    
    
    init(name: String, id: String, location: Location?, profileImagePath: String?, currentLocation: Location?, rating: Double) {
        self.currentLocation = currentLocation
        self.rating = rating
        super.init(name: name, id: id, location: location, profileImagePath: profileImagePath)
    }
}
