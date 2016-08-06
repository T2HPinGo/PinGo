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
    var woker: Worker?
    var id: String?
    var category: Category?
    var title: String
    var status: Status?
    var issueImageVideoPath: String?
}



