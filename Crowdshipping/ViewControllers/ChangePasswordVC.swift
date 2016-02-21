//
//  ChangePasswordVC.swift
//  Crowdshipping
//
//  Created by Ivan Kozlov on 18/06/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

class ChangePasswordVC: ConnectionAwareVC, UITextFieldDelegate, UIAlertViewDelegate {

    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var oldError: UILabel!
    @IBOutlet weak var newError: UILabel!
    @IBOutlet weak var confirmError: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addBackgroundRecognizer()
        
        oldPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        continueButton.backgroundColor = Utils.Color(220, 220, 220)
        continueButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: oldPasswordTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: newPasswordTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: confirmPasswordTextField)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textChanged(textField: UITextField)
    {
        
        if (oldPasswordTextField.text?.characters.count >= 6 &&
            newPasswordTextField.text?.characters.count >= 6 &&
            confirmPasswordTextField.text?.characters.count >= 6 /*&&
            newPasswordTextField.text == confirmPasswordTextField.text*/)
        {
            continueButton.backgroundColor = Utils.Color(12, 146, 254)
            continueButton.enabled = true
        }
        else
        {
            continueButton.backgroundColor = Utils.Color(220, 220, 220)
            continueButton.enabled = false
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if textField == oldPasswordTextField
        {
            newPasswordTextField.becomeFirstResponder()
        }
        else if textField == newPasswordTextField
        {
            confirmPasswordTextField.becomeFirstResponder()
        }
    
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField == oldPasswordTextField
        {
            oldError.hidden = textField.text?.characters.count > 5
        }
        else if textField == newPasswordTextField
        {
            newError.hidden = textField.text?.characters.count > 5
        }else if textField == confirmPasswordTextField
        {
            confirmError.hidden = textField.text?.characters.count > 5
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        
        let text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString:string)
        
        if textField == oldPasswordTextField && oldError.hidden == false
        {
            oldError.hidden = text.characters.count < 6
        }
        else if textField == newPasswordTextField && newError.hidden == false
        {
            newError.hidden = text.characters.count < 6
        }else if textField == confirmPasswordTextField && confirmError.hidden == false
        {
            confirmError.hidden = text.characters.count < 6
        }
        
        return true
    }
    
    @IBAction func confirmTap() {
        
        if newPasswordTextField.text != confirmPasswordTextField.text
        {
            let av = UIAlertView(title: "Validation error",
                message: "Confirm password did not match",
                delegate: nil,
                cancelButtonTitle: "OK")
            av.show()
            
            return
        }
        
        
        
        continueButton.enabled = false
        self.showWaitOverlay()
        
        APIManager.sharedInstance.changePassword(oldPasswordTextField.text!,
            newPassword: newPasswordTextField.text!,
            successCallback: { () -> Void in
                self.continueButton.enabled = true
                self.removeAllOverlays()
                let av = UIAlertView(title: "Your password was changed",
                    message: "Please sign in with new password",
                    delegate: self,
                    cancelButtonTitle: "OK")
                av.show()
            }) { (json) -> Void in
                self.continueButton.enabled = true
                self.removeAllOverlays()
                Utils.showErrorForJSON(json)
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int)
    {
        OrderManager.sharedInstance.deleteSavedOrder()
        
        NotificationManager.post(.UserDidLogout)
        
        AuthManager.sharedInstance.logout()
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.performSegueWithIdentifier("register", sender: self)
        
        delegate.resetNavigationStack()
        let mainController = delegate.mainMapNavigation.viewControllers[0] as? MapVC
        mainController?.shouldResetMap = true
        delegate.leftMenu.reloadHeader()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

}
