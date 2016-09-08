//
//  Category.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

public enum Category: String {
    case Electricity = "Electricity"
    case Cleanning = "Cleanning"
    case Plumbing = "Plumbing"
    case AutoRepair = "Auto Repair"
    case Gardening = "Gardening"
}


class TicketCategory: NSObject {
    var id: String?
    var title: String?
    var iconImage: String?
    static let categoryNames = ["Electricity", "Cleanning",
                        "Plumbing", "Auto Repair", "Gardening"]
    
    static let categoryIcons = ["Electricity", "Housekeeping", "Plumbing", "Maintenance", "Garden"]
}
