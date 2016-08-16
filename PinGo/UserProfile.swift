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
   
    var averageRating: Double?
    // Hien code
    var firstName: String?
    var lastName: String?
    var name: String?
    var profileImagePath: String?
    var dataJson: [String: AnyObject]?
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
        averageRating = 0
    }
    
    // Hien Code
    init(name: String, id: String, location: Location?, profileImagePath: String?) {
        self.name = name
        self.id = id
        self.location = Location()
        self.profileImagePath = ""
        //self.isWorker = isWorker
    }
    
    init (data: [String:AnyObject]){
         print(data)
        self.dataJson = data
        username = data["username"] as? String
        email = data["email"] as? String
        isWorker = data["isWorker"] as? Bool
        phoneNumber = data["phoneNumber"] as? String
        id = data["_id"] as? String
        print(data["phoneNumber"])
        location = Location(data: (data["location"] as? [String: AnyObject])!)
        profileImage = ImageResource(data: (data["profileImage"] as? [String: AnyObject])!)
        if let averageRating = data["averageRating"] as? Double {
            self.averageRating = averageRating
        }
    }
    
    func setTempData(data: [String: AnyObject]) {
        username = data["username"] as? String
        phoneNumber = data["phoneNumber"] as? String
        id = data["_id"] as? String
        profileImage = ImageResource(data: (data["profileImage"] as? [String: AnyObject])!)
    }
    
  
    
    //create currentuser info
    static var _currentUser: UserProfile?
    
    static let userDidLogOutNotification = "UserDidLogout"
    
    class var currentUser: UserProfile? {
        get{
            if _currentUser == nil{
                let defaults = NSUserDefaults.standardUserDefaults()
                let userData = defaults.objectForKey("currentUserData") as? NSData
                
                if let userData = userData {
                    let dictionary = try! NSJSONSerialization.JSONObjectWithData(userData, options: []) as! NSDictionary
                    _currentUser = UserProfile(data: dictionary as! [String : AnyObject])
                }
            }
            
            return _currentUser
        }
        set(user){
            _currentUser = user
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if let user = user {
                let data = try! NSJSONSerialization.dataWithJSONObject(user.dataJson!,options: [])
                
                defaults.setObject(data, forKey: "currentUserData")
            } else  {
                defaults.setObject(nil, forKey: "currentUserData")
            }
            defaults.synchronize()
            
        }
    }
}
