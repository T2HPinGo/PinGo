//
//  T2HGradient.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/10/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class T2HGradientUIView: UIView {
    //MARK: - Properties
    var startColor: UIColor = UIColor.whiteColor() {
        didSet{
            setupGradient()
        }
    }
    
    var endColor: UIColor = UIColor.whiteColor() {
        didSet{
            setupGradient()
        }
    }
    
    var direction: GradientDirection = .Horizontal{
        didSet{
            setupGradient()
        }
    }
    
    var cornerRadius: CGFloat = 0.0 {
        didSet{
            setupGradient()
        }
    }
    
    var gradientLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupGradient()
    }
    
    
    //MARK: - Functions
    func setupGradient() {
        let colors = [startColor.CGColor, endColor.CGColor]
        
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = cornerRadius
        
        switch direction {
        case .Horizontal:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        case .Vertical:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        case .DiagonalUp:
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        case .DiagonalDown:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        default:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        }
        
        setNeedsDisplay()
    }
    
    
    
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }
    

    enum GradientDirection {
        case Horizontal
        case Vertical
        case DiagonalUp
        case DiagonalDown
    }
    
}
