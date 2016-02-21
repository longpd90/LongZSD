//
//  TopBottomBorderView.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 07/05/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

@IBDesignable
class TopBottomBorderView: UIView {

    var upperBorder: CALayer?
    var lowerBorder: CALayer?
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.customInit()
    }
    
    func customInit() {
        self.setupBorders()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupBorders()
    }
    
    func setupBorders() {
        if (upperBorder != nil) {
            upperBorder?.removeFromSuperlayer()
        }
        if (lowerBorder != nil) {
            lowerBorder?.removeFromSuperlayer()
        }
        
        upperBorder = CALayer()
        upperBorder!.backgroundColor = Config.Visuals.color_gray_border.CGColor
        upperBorder!.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 1.0)
        self.layer.addSublayer(upperBorder!)
        
        lowerBorder = CALayer()
        lowerBorder!.backgroundColor = Config.Visuals.color_gray_border.CGColor
        lowerBorder!.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 1.0, CGRectGetWidth(self.frame), 1.0)
        self.layer.addSublayer(lowerBorder!)
    }
}
