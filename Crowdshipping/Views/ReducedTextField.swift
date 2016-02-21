//
//  ReducedTextField.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 13/05/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class ReducedTextField: UITextField {
    override func caretRectForPosition(position: UITextPosition) -> CGRect {
        return CGRectZero
    }
    
    override func selectionRectsForRange(range: UITextRange) -> [AnyObject] {
        return []
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == Selector("copy:") ||
            action == Selector("selectAll:") ||
            action == Selector("paste:")
        {
            return false
        }
        
        
        return super.canPerformAction(action, withSender: sender)
    }
}
