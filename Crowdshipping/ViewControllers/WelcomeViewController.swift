//
//  WelcomeViewController.swift
//  Crowdshipping
//
//  Created by Ivan Kozlov on 29/05/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var continueButton: UIButton!
    
    internal var buttonTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let pickupPhone = OrderManager.sharedInstance.currentOrder.pickupPhone
        {
            continueButton.setTitle("CONTINUE YOUR ORDER", forState: .Normal)
        }
    }
    
}
