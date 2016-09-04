//
//  PingoFilter.swift
//  PinGo
//
//  Created by Hien Quang Tran on 9/4/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import Foundation

class PingoFilter {
    var distanceFilter: Double?
    var priceFrom: Double?
    var priceTo: Double?
    
    init() {
        distanceFilter = 0.0
        priceFrom = 0.0
        priceTo = 0.0
    }
    
    func resetFilter() {
        distanceFilter = 0.0
        priceFrom = 0.0
        priceTo = 0.0
    }
    
    
    func filterFromDistance(distanceArray: [Double]) -> [Double] {
        if distanceFilter != 0 {
            if let distanceFilter = distanceFilter {
                return distanceArray.filter({$0 < distanceFilter } )
            }
        }
        
        //if distance == 0, meaning filter from any distance
        return distanceArray
    }
    
    func comparePriceFrom(priceFrom: Double, to priceTo: Double) -> CompareOrder {
        if priceFrom < priceTo {
            return .OrderAscending
        } else if priceFrom == priceTo {
            return .OrderSame
        } else {
            return .OrderDescending
        }
    }
}

enum CompareOrder {
    case OrderSame
    case OrderAscending
    case OrderDescending
}
