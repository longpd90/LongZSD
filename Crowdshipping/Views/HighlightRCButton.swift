//
//  HighlightRCButton.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 08/05/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

@IBDesignable
class HighlightRCButton: RoundedCornerButton {
    override var highlighted: Bool {
        get {
            return super.highlighted
        }
        set {
            if newValue {
                backgroundColor = Config.Visuals.color_graySizeSelected
            }
            else {
                backgroundColor = Config.Visuals.color_graySizeUnselected
            }
            super.highlighted = newValue
        }
    }
}
