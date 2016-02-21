//
//  phoneTextField.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 13/04/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class PhoneTextField: UITextField, UITextFieldDelegate {
    let util = NBPhoneNumberUtil()

    final let validCharSet: NSMutableCharacterSet = {
        let set = NSMutableCharacterSet.decimalDigitCharacterSet()
        set.addCharactersInString("+")
        return set
    }()

    override func awakeFromNib() {
        self.delegate = self
    }
    
    func isValid() -> Bool {
        let filteredStr = (self.text!.componentsSeparatedByCharactersInSet(self.validCharSet.invertedSet) as [String]).joinWithSeparator("")
        var phoneNumber: NBPhoneNumber?
        do {
            phoneNumber = try self.util.parse(filteredStr, defaultRegion:"SG")
        } catch {
            
        }
        
        return self.util.isValidNumber(phoneNumber)
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let formatter = NBAsYouTypeFormatter(regionCode: "SG")
        
        
        let newStr = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let filteredStr = (newStr.componentsSeparatedByCharactersInSet(validCharSet.invertedSet) as [String]).joinWithSeparator("")
        
        self.text = formatter.inputString(filteredStr)
        
        if self.isValid() {
            self.textColor = UIColor.blackColor()
        } else {
            self.textColor = UIColor.redColor()
        }
        
        return false
    }
}
