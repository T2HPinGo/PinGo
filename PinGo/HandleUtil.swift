//
//  HandleUtil.swift
//  PinGo
//
//  Created by Cao Thắng on 8/20/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import Foundation
import Alamofire
import AFNetworking
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
        let url = NSURL(string: stringUrl)
        let imageRequest = NSURLRequest(URL: url!)
        imageView.tintColor = UIColor.orangeColor()
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
    
    static func formatDateToLongDate(timestamp: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateFormat = "h:mm a '-' MMMM dd, yyyy"
        dateFormatter.AMSymbol = "AM"
        dateFormatter.PMSymbol = "PM"
        return  dateFormatter.stringFromDate(timestamp)
    }
    static func changeUnixDateToNSDate(unixTime: String) -> String {
        let number = Int(unixTime)
        let myNumber = NSNumber(integer:number!)
        let epocTime = NSTimeInterval(myNumber)
        
        let myDate = NSDate(timeIntervalSince1970:  epocTime)
        return getStringFromDate(myDate, withFormat: DateStringFormat.DD_MMM_YYYY_HH_mm)
    }
    
    static func castStringToNSNumber(data: String) ->NSNumber {
        var result: NSNumber?
        let tempDouble = Double(data)
        result = tempDouble
        return result!
    }
    static func convertCurrencyStringToNsNumber (data: String) -> Double {
        let indexStartOfText = data.startIndex.advancedBy(1)
        let subString = data.substringFromIndex(indexStartOfText)
        let number = Int(subString)
        return Double(number!)

    }
    
    static func convertStringToDouble(target: String) -> Double{
        let number = Int(target)
        return Double(number!)
    }
}
