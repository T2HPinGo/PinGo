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
    var user: User?
    var worker: Worker?
    var id: String?
    var category: String?//TicketCategory?
    var title: String?
    var status: Status?
    var issueImageVideoPath: String?
    var dateCreated: NSDate?
    
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



