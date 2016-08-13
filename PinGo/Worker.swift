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
    }
    
}
