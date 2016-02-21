//
//  DefaultButton.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 07/05/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class DefaultButton: UIButton {

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
        // Do nothing
    }
}
