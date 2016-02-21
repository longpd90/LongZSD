//
//  RoundedCornerButton.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 07/05/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedCornerButton: DefaultButton {
    override func customInit() {
        self.layer.cornerRadius = Config.Visuals.cornerRadius
        self.layer.masksToBounds = true
    }
}
