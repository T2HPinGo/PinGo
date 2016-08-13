//
//  Ticket.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

enum Status {
    case Pending
    case Confirmed
    case Done
    case Cancel
}

class Ticket: NSObject {
    var category: String?
    var title: String?
    var workerName: String?
    var userName: String?
    var urgent: Bool?
    var user: UserProfile?
    var worker: Worker?
    var status: String?
    var imageOne: ImageResource?
    var imageTwo: ImageResource?
    var imageThree: ImageResource?
    var location: Location?
    
    override init() {
        category = ""
        title = ""
        urgent = true
        user = UserProfile()
        worker = Worker()
        status = ""
        imageOne = ImageResource()
        imageTwo =  ImageResource()
        imageThree = ImageResource()
        location = Location()
    }
    init(data: [String: AnyObject]){
        category = data["category"] as? String
        title = data["title"] as? String
        urgent  = data["urgent"] as? Bool
        let createBy = data["createBy"] as? [String: AnyObject]
        user = UserProfile(data: createBy!)
    }
    
}




