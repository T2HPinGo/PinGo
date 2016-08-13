//
//  User.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class UserProfile: NSObject {
    var username: String?
    var email: String?
    var isWorker: Bool?
    var phoneNumber: String?
    var id: String?
    var location: Location?
    var profileImage: ImageResource?
    
    override init() {
        super.init()
        username = ""
        email = ""
        isWorker = false
        phoneNumber  = ""
        id = ""
        location = Location()
        profileImage = ImageResource()
        profileImage?.width = 60
        profileImage?.height = 60
    }
    init (data: [String:AnyObject]){
        username = data["username"] as? String
        email = data["email"] as? String
        isWorker = data["isWorker"] as? Bool
        phoneNumber = data["phoneNumber"] as? String
        id = data["_id"] as? String
        location = Location(data: (data["location"] as? [String: AnyObject])!)
        profileImage = ImageResource(data: (data["profileImage"] as? [String: AnyObject])!)
    }
}
