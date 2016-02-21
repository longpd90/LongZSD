//
//  UserBlockedVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 05/05/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

// @objc needed to load xib properly
@objc(UserBlockedVC) class UserBlockedVC: ConnectionAwareVC {
    @IBOutlet var buttonContainer: UIView!
    @IBOutlet var reasonLabel: UILabel!
    
    var reason: String?
    var nc: UINavigationController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if reason != nil {
//            reasonLabel.text = reason
//        }
        
        buttonContainer.layer.cornerRadius = Config.Visuals.cornerRadius
        buttonContainer.layer.masksToBounds = true
        
        self.title = "YOUR ACCOUNT IS BLOCKED"
        
        self.addBackgroundRecognizer()
        self.setEditing(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Remove keyboard
        let tf = UITextField()
        self.view.addSubview(tf)
        tf.becomeFirstResponder()
        tf.resignFirstResponder()
        tf.removeFromSuperview()
    }
    
    @IBAction func callOfficeTap() {
        Utils.callPhoneNumber(Config.officePhone)
    }
    
    @IBAction func signInWithAnotherAccountTap() {
        
        UIView.animateWithDuration(Config.animationDurationDefault, animations: { () -> Void in
            self.nc!.view.alpha = 0
        }) { (arg) -> Void in
            self.nc!.view.removeFromSuperview()
            self.nc = nil
        }
    }
}
