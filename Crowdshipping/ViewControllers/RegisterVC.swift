//
//  RegisterVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 16/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class RegisterVC: ConnectionAwareVC, UITextFieldDelegate
{
    
    @IBOutlet weak var phoneTextField: DropdownPhoneTF!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var switchSkipButtonTitle = false
    var phone: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneTextField.parentViewController = self
        
        self.addBackgroundRecognizer()
        
        registerButton.enabled = false;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "confirm phone":
            (segue.destinationViewController as! ConfirmPhoneVC).phone = phone
        default:
            break
        }
    }
    
    // MARK: UI callbacks
    
    @IBAction func registerTap(sender: AnyObject) {
        phone           = phoneTextField.getPhone()
        let password        = passwordTextField.text

        errorLabel.text = ""
        
        if (!phoneTextField.isValid()) {
            let av = UIAlertView(title: "The phone number is wrong",
                message: "",
                delegate: nil,
                cancelButtonTitle: "OK")
            av.show()
            
            return
        }
        
        if (!(password?.characters.count >= Config.minPasswordLength)) {
            let av = UIAlertView(title: "Error",
                message: "Password should be at least \(Config.minPasswordLength) characters",
                delegate: nil,
                cancelButtonTitle: "OK")
            av.show()
            
            return
        }
        
        
        registerButton.enabled = false;
        
        self.showWaitOverlay()
        weak var wSelf = self;
        
//        APIManager.sharedInstance.register(phone!, password: password,
//            successCallback: ({ () -> Void in
//                let sSelf = wSelf
//                
//                if (sSelf != nil) {                    
//                    APIManager.sharedInstance.bindPhone(self.phone!,
//                        successCallback: { (arg) -> Void in
//                            self.removeAllOverlays()
//                            
//                            self.performSegueWithIdentifier("confirm phone", sender: self)
//                        }) { (arg) -> Void in
//                            self.removeAllOverlays()
//                            
//                            Utils.showErrorForJSON(arg)
//                    }
//                }
//            }),
//            failedCallback: ({ (json) -> Void in
//                let sSelf = wSelf
//                
//                if (sSelf != nil) {
//                    sSelf!.removeAllOverlays()
//                    sSelf!.registerButton.enabled = true;
//                    
//                    if let code = json?["code"] as? String
//                    {
//                        if code == "validation_error"
//                        {
//                            let av = UIAlertView(title: "This phone number is already in use",
//                                message: "Try another one",
//                                delegate: nil,
//                                cancelButtonTitle: "OK")
//                            av.show()
//                        }
//                        else
//                        {
//                            Utils.showErrorForJSON(json)
//                        }
//                    }
//                    
//                    if let fieldErrors = Utils.fieldsErrorDescriptionForJSON(json) {
//                        self.errorLabel.text = fieldErrors
//                    }
//                }
//            }))
    }
    
    @IBAction func alreadyRegisteredTap(sender: AnyObject) {
        self.performSegueWithIdentifier("login", sender: self)
    }
    
    @IBAction func skipTap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var phone = phoneTextField.getPhone()
        var password = passwordTextField.text
        
        if (textField == passwordTextField)
        {
            password = password!.stringByReplacingCharactersInRange(range.toRange(password!), withString: string)
        }
        
        if (phoneTextField.isValid() &&
            (password?.characters.count >= Config.minPasswordLength))
        {
            self.registerButton.backgroundColor = Config.Visuals.color_registerButton
            self.registerButton.enabled = true
        }
        else
        {
            self.registerButton.backgroundColor = Config.Visuals.color_grayButton
            self.registerButton.enabled = false
        }

        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == phoneTextField {
            passwordTextField.becomeFirstResponder()
            return true
        }
        
        if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            return true
        }
        return true
    }
}