//
//  UIViewController.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 25/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation

extension UIViewController {
    func addBackgroundRecognizer() {
//        let holder = UIView(frame: self.view.bounds)
        self.view.userInteractionEnabled = true
//        self.view.insertSubview(holder, atIndex: 9999)
        
        let recognizer = UITapGestureRecognizer(target: self, action: Selector("ext_backgroundTap"))
        self.view.addGestureRecognizer(recognizer)
    }
    
    func ext_backgroundTap() {
        self.view.endEditing(true)
    }
}