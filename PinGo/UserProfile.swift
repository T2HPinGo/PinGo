//
//  User.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class UserProfile: NSObject {
    var name: String?
    var id: String?
    var location: Location?
    var profileImagePath: String?
    //var isWorker: Bool?   //true = worker, false = user
    
    init(name: String, id: String, location: Location?, profileImagePath: String?) {
        self.name = name
        self.id = id
        self.location = location
        self.profileImagePath = profileImagePath
        //self.isWorker = isWorker
    }
}
