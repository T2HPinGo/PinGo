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
    var isWorker: Bool = false
    var phoneNumber: String?
    var id: String?
    var location: Location?
    var profileImage: ImageResource?
   
    var averageRating: Double = 0
    var firstName: String = ""
    var lastName: String = ""
    var dataJson: [String: AnyObject]?
    var category: String = ""
    var price: String = ""
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
    
    init (data: [String:AnyObject]){
         print(data)
        self.dataJson = data
        if let username = data["username"] as? String {
            self.username = username
        } else {
            self.username = ""
        }
        email = data["email"] as? String
        isWorker = data["isWorker"] as! Bool
        if let phoneNumber = data["phoneNumber"] as? String {
            self.phoneNumber = phoneNumber
        } else {
            self.phoneNumber = ""
        }
        if let id = data["_id"] as? String {
            self.id = id
        } else {
            if let id = data["id"] as? String {
                self.id = id
            }
        }
        print(data["phoneNumber"])
        location = Location(data: (data["location"] as? [String: AnyObject])!)
        profileImage = ImageResource(data: (data["profileImage"] as? [String: AnyObject])!)
        if let averageRating = data["averageRating"] as? Double {
            self.averageRating = averageRating
        }
        if let category = data["category"] as? String{
            self.category = category
        }
        
        if let firstName = data["firstname"] as? String {
            self.firstName = firstName
        }
        
        if let lastName = data["lastname"] as? String{
            self.lastName = lastName
        }
        if isWorker {
            if let price = data["price"] as? String {
                self.price = price
            }
            
        }
    }
    
    func setTempData(data: [String: AnyObject]) {
        username = data["username"] as? String
        if let phoneNumber = data["phoneNumber"] as? String {
            self.phoneNumber = phoneNumber
        }
        if let id = data["_id"] as? String {
            self.id = id
        } else {
            if let id = data["id"] as? String {
                self.id = id
            }
        }
        profileImage = ImageResource(data: (data["profileImage"] as? [String: AnyObject])!)
        
        if let firstName = data["firstname"] as? String {
            self.firstName = firstName
        }
        
        if let lastName = data["lastname"] as? String{
            self.lastName = lastName
        }
        if let price = data["price"] as? String {
            self.price = price
        }
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
    func getFullName()-> String{
        if firstName != "" && lastName != "" {
            return firstName + lastName
        }
        return username!
    }
}
