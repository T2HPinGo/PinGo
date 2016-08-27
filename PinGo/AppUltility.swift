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
    case DD_MMM_YYYY_HH_mm = "dd MMM yyyy, hh:mm"
    case MMM_yyyy = "MMM yyyy"
    case MMM = "MMM"
    
}

func getStringFromDate(date: NSDate, withFormat format: DateStringFormat) -> String {
    let formatter = NSDateFormatter()
    formatter.dateFormat = format.rawValue
    return formatter.stringFromDate(date)    
}
