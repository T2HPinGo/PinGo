//
//  Worker.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class Worker: UserProfile {
    
 
    override init() {
        super.init()
    }
    override init(data: [String : AnyObject]) {
        super.init(data: data)
        
    }
    
    var currentLocation: Location?
    var rating: Double?
}
