//
//  phoneTextField.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 13/04/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

protocol DropdownPhoneTFDelegate {
    func dropdownPhoneTFDidChangeValue(field: DropdownPhoneTF)
}

class DropdownPhoneTF: UIView, PhoneCodeDelegate, UITextFieldDelegate {
    var parentViewController: UIViewController?
    var delegate: DropdownPhoneTFDelegate?
    
    private var codeButton: UIButton?
    internal var textField: UITextField?
    
    private var phoneCode = Config.phonePrefix
    let util = NBPhoneNumberUtil()
    let phoneCodeButtonWidth = CGFloat(40)
    
    final let validCharSet: NSMutableCharacterSet = {
        let set = NSMutableCharacterSet.decimalDigitCharacterSet()
        set.addCharactersInString("+")
        return set
    }()

    override func awakeFromNib() {
        self.backgroundColor = UIColor.clearColor()
        
        codeButton = UIButton(frame: CGRectMake(0, 0, phoneCodeButtonWidth, self.frame.size.height))

        codeButton!.setTitle(phoneCode, forState: .Normal)
        codeButton!.setTitleColor(Config.Visuals.color_grayText, forState: .Normal)
        codeButton!.addTarget(self, action:Selector("phoneCodeTap"), forControlEvents:.TouchUpInside)
        codeButton!.sizeToFit()
        codeButton!.titleLabel!.textAlignment = .Left
        codeButton!.contentHorizontalAlignment = .Left
        
        codeButton!.titleLabel!.adjustsFontSizeToFitWidth = true
        codeButton!.titleLabel!.minimumScaleFactor = 0.5
        
        self.addSubview(codeButton!)

        
        textField = UITextField(frame: CGRectMake(phoneCodeButtonWidth, 0, self.frame.size.width - phoneCodeButtonWidth, self.frame.size.height))
        textField!.keyboardType = UIKeyboardType.NumberPad
        textField!.placeholder = "Phone"
        textField!.clearButtonMode = UITextFieldViewMode.WhileEditing
        textField!.delegate = self
        textField!.textColor = Config.Visuals.color_grayText
        self.addSubview(textField!)
    }
    
    override func layoutSubviews() {
        codeButton!.frame = CGRectMake(0, 0, phoneCodeButtonWidth, self.frame.size.height)
        textField!.frame = CGRectMake(phoneCodeButtonWidth, 0, self.frame.size.width - phoneCodeButtonWidth, self.frame.size.height)
    }

    // MARK: UI callbacks
    
    @IBAction func phoneCodeTap() {
        if Config.isDevBuild
        {
            let pcvc = PhoneCodeVC()
            pcvc.delegate = self
            
            let nc = UINavigationController(rootViewController: pcvc)
            self.parentViewController!.presentViewController(nc, animated: true) { () -> Void in }
        }
    }
    
    // MARK: PhoneCodeDelegate
    
    @objc func setPhoneCode(code: String) {
        phoneCode = "+" + code
        codeButton!.setTitle(phoneCode, forState: .Normal)
        
        self.delegate?.dropdownPhoneTFDidChangeValue(self)
    }
    
    // MARK: UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.delegate?.dropdownPhoneTFDidChangeValue(self)
            return
        }
        
        return true
    }
    
    // MARK: Public
    
    func getPhone() -> String {
        return phoneCode + textField!.text!
    }
    
    func setPhone(newPhone: String) {
        var nationalNumber: NSString?
        let countryCode = util.extractCountryCode(newPhone, nationalNumber: &nationalNumber)
        
        setPhoneCode(countryCode.stringValue)
        if nationalNumber != nil {
            textField?.text = nationalNumber as? String
        }

        self.delegate?.dropdownPhoneTFDidChangeValue(self)
    }
    
    func isValid() -> Bool {
        let filteredStr = phoneCode + (textField!.text!.componentsSeparatedByCharactersInSet(self.validCharSet.invertedSet) as [String]).joinWithSeparator("")
        
        var phoneNumber: NBPhoneNumber?
        do {
            phoneNumber = try self.util.parse(filteredStr, defaultRegion:"SG")
        } catch {
            
        }
        return self.util.isValidNumber(phoneNumber)
    }
    
    func setAccessoryView(accessoryView: UIView?) {
        textField!.inputAccessoryView = accessoryView
    }
}
