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
    var status: Status?
    var imageOne: ImageResource?
    var imageTwo: ImageResource?
    var imageThree: ImageResource?
    var location: Location?
    var id: String?
    
    // Hien Code 
    var issueImageVideoPath: String?
    var dateCreated: NSDate?
    override init() {
        category = ""
        title = ""
        urgent = true
        user = UserProfile()
        worker = Worker()
        status = Status.Pending
        imageOne = ImageResource()
        imageTwo =  ImageResource()
        imageThree = ImageResource()
        location = Location()
    }
    init(data: [String: AnyObject]){
        id = data["_id"] as? String
        category = data["category"] as? String
        title = data["title"] as? String
        urgent  = data["urgent"] as? Bool
        let createBy = data["createBy"] as? [String: AnyObject]
        user = UserProfile(data: createBy!)
    }
    
    init(user: User, worker: Worker, id: String, category: String, title: String, status: Status, issueImageVideoPath: String?, dateCreated: NSDate) {
        self.user = user
        self.worker = worker
        self.id = id
        self.category = category
        self.title = title
        self.status = status
        self.issueImageVideoPath = issueImageVideoPath
        self.dateCreated = dateCreated
    }
    
}




