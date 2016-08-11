//
//  T2HGradientView.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/10/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class T2HGradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }
    
    //UIView requires all subclasses implement this
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
    }
    
    //should use lazy loading when create gradient
    override func drawRect(rect: CGRect) {
        //colors and location for colors
        let components: [CGFloat] = [198.0/255.0, 53.0/255.0, 50.0/255.0, 0.3,
                                     185.0/255.0, 40.0/255.0, 105.0/255.0, 0.7] //array contain value for colors (0, 0, 0, 0.3) means black with 30% transparent, (0, 0, 0, 0.3) means black with 70% transparent
        let locations: [CGFloat] = [0,  1]
        
        //
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2)
        
        let x = CGRectGetMidX(bounds)
        let y = CGRectGetMidY(bounds)
        let point = CGPoint(x: x, y: y)
        let radius = max(x, y)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawRadialGradient(context, gradient, point, 0, point, radius, .DrawsAfterEndLocation)
    }
}