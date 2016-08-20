//
//  HandleUtil.swift
//  PinGo
//
//  Created by Cao Thắng on 8/20/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import Foundation
import Alamofire

struct HandleUtil {
    static func getOneWordOfStatus(status: String) ->String{
        switch status {
        case Status.Pending.rawValue:
            return "P"
        case Status.InService.rawValue:
            return "I"
        case Status.Done.rawValue:
            return "D"
        default:
            return ""
        }
    }
    static func loadImageViewWithUrl(sourceImage: String, imageView: UIImageView){
        
        let stringUrl = "\(API_URL)\(PORT_API)/v1\(sourceImage)"
        print("URl: \(stringUrl)")
        let url = NSURL(string: stringUrl)
        let imageRequest = NSURLRequest(URL: url!)
        
        imageView.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    imageView.alpha = 0.0
                    imageView.image = image
                    UIView.animateWithDuration(0.7, animations: { () -> Void in
                        imageView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    imageView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
    }
}
