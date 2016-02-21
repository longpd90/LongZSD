//
//  RegisterVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 16/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class LoginVC: ConnectionAwareVC {
    @IBOutlet weak var phoneTextField: DropdownPhoneTF!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneTextField.parentViewController = self
        
        self.addBackgroundRecognizer()
        
        //        if let pickupPhone = OrderManager.sharedInstance.currentOrder.pickupPhone?
        if let pickupPhone = OrderManager.sharedInstance.currentOrder.pickupPhone
        {
            phoneTextField.setPhone(pickupPhone)
        }
        
        self.loginButton.backgroundColor = Config.Visuals.color_grayButton
        self.loginButton.enabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "forgot password":
            //            (segue.destinationViewController as RestorePasswordVC).phone = phoneTextField.getPhone()
            (segue.destinationViewController as! RestorePasswordVC).phone = phoneTextField.getPhone()
        default:
            break
        }
    }
    
    // MARK: UI callbacks
    
    //    @IBAction func loginTap(AnyObject) {
    @IBAction func loginTap(sender: AnyObject) {
        let phone           = phoneTextField.getPhone()
        let password        = passwordTextField.text
        
        errorLabel.text = ""
        
        /*
        if !Utils.validateValue(phoneTextField, validator: { (val) -> Bool in val.isValid() },
        errorMessage: "Phone is not valid")
        { return }
        */
        
        if (!phoneTextField.isValid()) {
            let av = UIAlertView(title: "Error",
                message: "Phone is not valid",
                delegate: nil,
                cancelButtonTitle: "OK")
            av.show()
            
            return;
        }
        
        loginButton.enabled = false;
        
        self.showWaitOverlay()
        weak var wSelf = self;
        
        APIManager.sharedInstance.login(phone, password: password!,
            successCallback: ({ () -> Void in
                let sSelf = wSelf
                
                DefaultsManager.set(phone, forKey: .LastSuccessfullLoginPhone)
                
                if (sSelf != nil) {
                    sSelf!.removeAllOverlays()
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    
                    
                    if !AuthManager.sharedInstance.getHasPaymentMethod()
                    {
                        appDelegate.leftMenu.reloadHeader()
                        sSelf!.performSegueWithIdentifier("bind card", sender: self)
                    }
                    else
                    {
                        
                        if OrderManager.sharedInstance.currentOrder.pickupPhone != nil
                        {
                            appDelegate.leftMenu.reloadHeader()
                            sSelf!.dismissViewControllerAnimated(true, completion: nil)
                        }
                        else
                        {
                            appDelegate.showWelcome({ () -> Void in
                                appDelegate.leftMenu.reloadHeader()
                                sSelf!.dismissViewControllerAnimated(true, completion: nil)
                            })
                        }
                    }
                }
            }),
            failedCallback: ({ (json) -> Void in
                let sSelf = wSelf
                
                if (sSelf != nil) {
                    sSelf!.removeAllOverlays()
                    sSelf!.loginButton.enabled = true;
                    
                    if let code = json?["code"] as? String
                    {
                        print(code)
                        if code == "invalid_credentials"
                        {
                            let av = UIAlertView(title: "You've entered wrong credentials",
                                message: "",
                                delegate: nil,
                                cancelButtonTitle: "OK")
                            av.show()
                        }
                        else
                        {
                            Utils.showErrorForJSON(json)
                        }
                    }
                    
                    if let fieldErrors = Utils.fieldsErrorDescriptionForJSON(json) {
                        Utils.log(fieldErrors)
                        self.errorLabel.text = fieldErrors
                    }
                }
            }))
    }
    
    @IBAction func notRegisteredTap() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func forgotPasswordTap() {
        self.performSegueWithIdentifier("forgot password", sender: self)
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
            self.loginButton.backgroundColor = Config.Visuals.color_registerButton
            self.loginButton.enabled = true
        }
        else
        {
            self.loginButton.backgroundColor = Config.Visuals.color_grayButton
            self.loginButton.enabled = false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) {
        if textField == phoneTextField {
            passwordTextField.becomeFirstResponder()
            return
        }
        
        if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            return
        }
    }
}