//
//  RestorePasswordVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 20/04/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class RestorePasswordVC: ConnectionAwareVC{
    @IBOutlet weak var phoneTextField: DropdownPhoneTF!
    var phone: String?
    
    internal var isChangingPhone: Bool = false
    
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isChangingPhone
        {
            self.title = "ENTER NEW PHONE"
            
            continueButton.backgroundColor = Utils.Color(220, 220, 220)
            self.continueButton.enabled = false
        }
        else
        {
            self.title = "YOUR PHONE NUMBER"
            
            if let phone = DefaultsManager.get(.LastSuccessfullLoginPhone) as? String {
                phoneTextField.setPhone(phone)
            }
            else
            {
                continueButton.backgroundColor = Utils.Color(220, 220, 220)
                self.continueButton.enabled = false
            }
        }
        
        phoneTextField.parentViewController = self
        
        self.addBackgroundRecognizer()
        
        phoneTextField.textField?.placeholder = "Your phone number"
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: phoneTextField.textField)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textChanged(textField: UITextField)
    {
        if (phoneTextField.isValid())
        {
            continueButton.backgroundColor = Utils.Color(12, 146, 254)
            self.continueButton.enabled = true
        }
        else
        {
            continueButton.backgroundColor = Utils.Color(220, 220, 220)
            self.continueButton.enabled = false
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "confirm":
            let vc = (segue.destinationViewController as! ConfirmPasswordVC)
            vc.phone = phone
            vc.isChangingPhone = isChangingPhone
        default:
            break
        }
    }
    
    // MARK: UI callbacks
    
    @IBAction func restoreTap() {
        
        if (!phoneTextField.isValid()) {
            let av = UIAlertView(title: "Error",
                message: "Phone is not valid",
                delegate: nil,
                cancelButtonTitle: "OK")
            av.show()
            
            return;
        }
        
        phone = phoneTextField.getPhone()
        
        self.showWaitOverlay()
        continueButton.enabled = false
        if isChangingPhone
        {
            
            print(DefaultsManager.get(.Phone) as? String)
            if (DefaultsManager.get(.Phone) as? String) == phone
            {
                
                let av = UIAlertView(title: "Error",
                    message: "You are already using this phone",
                    delegate: nil,
                    cancelButtonTitle: "OK")
                av.show()
                
                self.removeAllOverlays()
                self.continueButton.enabled = true
                return
            }
            
            APIManager.sharedInstance.bindPhone(phone!,
                successCallback: { (json) -> Void in
                    self.removeAllOverlays()
                    self.continueButton.enabled = true
                    self.performSegueWithIdentifier("confirm", sender: self)
                }) { (json) -> Void in
                    self.removeAllOverlays()
                    self.continueButton.enabled = true
                    Utils.showErrorForJSON(json)
            }
        }
        else
        {
            APIManager.sharedInstance.restorePassword(phone!,
                successCallback: { () -> Void in
                    self.removeAllOverlays()
                    self.continueButton.enabled = true
                    self.performSegueWithIdentifier("confirm", sender: self)
                }) { (json) -> Void in
                    self.removeAllOverlays()
                    self.continueButton.enabled = true
                    Utils.showErrorForJSON(json)
            }
        }
    }
}
