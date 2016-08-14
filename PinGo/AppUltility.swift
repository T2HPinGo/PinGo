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
    let colorIndex = index % 10 - AppThemes.cellColors.count
    return colorIndex
}
