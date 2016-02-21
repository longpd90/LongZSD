//
//  KeyboardToolbar.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 12/05/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class KeyboardToolbar: UIToolbar {
    convenience init(parentView: UIView) {
        self.init()
        
        self.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
            target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done,
            target: parentView,
            action: Selector("endEditing:"))
        self.items = [flexBarButton, doneBarButton]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience required init(coder aDecoder: NSCoder) {
        Utils.log("Not supposed to be init-ed with coder")
        self.init(coder: aDecoder)
    }
}
