//
//  NewRegisterVC.swift
//  Crowdshipping
//
//  Created by Ivan Kozlov on 21/06/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

class NewRegisterVC: ConnectionAwareTableVC, UITextFieldDelegate
{

    @IBOutlet weak var phoneTextField: DropdownPhoneTF!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    var phone: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneTextField.parentViewController = self
        
//        self.addBackgroundRecognizer()
        
        self.registerButton.backgroundColor = Config.Visuals.color_grayButton
        self.registerButton.enabled = false
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        passwordTextField.delegate = self
        
//        self.tableView.backgroundView = UIImageView(image: UIImage(named: "Background"))
        
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
    
    @IBAction func registerTap(sender: AnyObject) {
        phone           = phoneTextField.getPhone()
        let password        = passwordTextField.text
        let firstName = firstNameTextField.text
        let lastName = lastNameTextField.text
                
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
        
        APIManager.sharedInstance.register(firstName!, lastName: lastName!, phone: phone!, password: password!,
            successCallback: ({ () -> Void in
                let sSelf = wSelf
                
                if (sSelf != nil) {
                    APIManager.sharedInstance.bindPhone(self.phone!,
                        successCallback: { (arg) -> Void in
                            self.removeAllOverlays()
                            
                            self.performSegueWithIdentifier("confirm phone", sender: self)
                        }) { (arg) -> Void in
                            self.removeAllOverlays()
                            
                            Utils.showErrorForJSON(arg)
                    }
                }
            }),
            failedCallback: ({ (json) -> Void in
                let sSelf = wSelf
                
                if (sSelf != nil) {
                    sSelf!.removeAllOverlays()
                    sSelf!.registerButton.enabled = true;
                    
                    if let code = json?["code"] as? String
                    {
                        if code == "validation_error"
                        {
                            let av = UIAlertView(title: "This phone number is already in use",
                                message: "Try another one",
                                delegate: nil,
                                cancelButtonTitle: "OK")
                            av.show()
                        }
                        else
                        {
                            Utils.showErrorForJSON(json)
                        }
                    }
                    
                }
            }))
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var phone = phoneTextField.getPhone()
        var password = passwordTextField.text
        var firstName = firstNameTextField.text
        var lastName = lastNameTextField.text
        
        if (textField == passwordTextField)
        {
            password = password!.stringByReplacingCharactersInRange(range.toRange(password!), withString: string)
        }else if (textField == firstNameTextField)
        {
            firstName = firstName!.stringByReplacingCharactersInRange(range.toRange(firstName!), withString: string)
        } else if (textField == lastNameTextField)
        {
            lastName = lastName!.stringByReplacingCharactersInRange(range.toRange(lastName!), withString: string)
        }
        
        if (phoneTextField.isValid() &&
            (password?.characters.count >= Config.minPasswordLength) &&
            !firstName!.isEmpty &&
            !lastName!.isEmpty)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        
        textField.resignFirstResponder()
        
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: .Top, animated: true)
        } else if textField == lastNameTextField {
            phoneTextField.becomeFirstResponder()
//            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), atScrollPosition: .Top, animated: true)
        } else if textField == phoneTextField {
            passwordTextField.becomeFirstResponder()
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: 3, inSection: 0), atScrollPosition: .Top, animated: true)
        } else if textField == passwordTextField {
            return true
        }
        
        return true
    }
}
