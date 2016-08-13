//
//  ImageResource.swift
//  PinGo
//
//  Created by Cao Thắng on 8/14/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import Foundation

class ImageResource : NSObject {
    var imageUrl: String?
    var width: NSNumber?
    var height: NSNumber?
    
    override init() {
        imageUrl = ""
        width = 0
        height = 0
    }
    init(data: [String: AnyObject]){
        imageUrl = data["imageUrl"] as? String
        width = data["width"] as? NSNumber
        height = data["height"] as? NSNumber
        
    }
}