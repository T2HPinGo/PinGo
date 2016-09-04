//
//  AppUltility.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import Foundation



//make repeated patern for the color cell, when the number of cell exceed the AppThemes.cellColors array, it goes to the first color in the array
func getCorrespnsingColorForCell(index: Int) -> Int {
    let colorIndex = index % AppThemes.cellColors.count
    return colorIndex
}


//date formatter
public enum DateStringFormat : String {
    case DD_MMM_YYYY = "dd MMM yyyy"
    case DD_MMM_YYYY_HH_mm = "dd MMM yyyy, HH:mm"
    case MMM_yyyy = "MMM yyyy"
    case MMM = "MMM"
    case HH_mm = "HH:mm"  //24 hour mode
    
}

func getStringFromDate(date: NSDate, withFormat format: DateStringFormat) -> String {
    let formatter = NSDateFormatter()
    formatter.dateFormat = format.rawValue
    return formatter.stringFromDate(date)    
}

func getDateFromString(string: String, withFormat format: DateStringFormat) -> NSDate? {
    let formatter = NSDateFormatter()
    formatter.dateFormat = format.rawValue
    
    if let date = formatter.dateFromString(string) {
        return date
    } else {
        return nil
    }
}

func roundToBeutifulNumber(value: Double, devidedNumber number: Int) -> Int{
    let fractionNum = value / Double(number)
    let roundedNum = Int(ceil(fractionNum))
    return roundedNum * number
}
