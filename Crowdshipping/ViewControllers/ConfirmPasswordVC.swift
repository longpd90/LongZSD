//
//  RestorePasswordVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 20/04/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class ConfirmPasswordVC: ConnectionAwareVC, UITextFieldDelegate {
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var resendCodeButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!

    var phone: String?
    var code: String?
    
    var timer: NSTimer?
    let interval = NSTimeInterval(1)
    var timeLeft = Config.phoneCodeResendInterval
    
    internal var isChangingPhone: Bool = false
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addBackgroundRecognizer()
        
        codeTextField.delegate = self
        
        self.title = "VERIFICATION CODE"
        resendCodeButton.titleLabel?.textAlignment = .Center
        descriptionLabel.text = "We have sent a sms code to your phone\n\(phone!)"
        
        startTimer()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: codeTextField)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func textChanged(textField: UITextField)
    {
        if (codeTextField.text?.characters.count >= 4)
        {
//            continueButton.hidden = false
        }
        else
        {
//            continueButton.hidden = true
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "new password":
            let vc = (segue.destinationViewController as! NewPasswordVC)
            vc.phone = phone
            vc.code = code
        default:
            break
        }
    }
    
    // MARK: other
    
    func startTimer() {
        resendCodeButton.enabled = false
        resendCodeButton.backgroundColor =  Utils.Color(220, 220, 220)
        resendCodeButton.setTitleColor(Config.Visuals.color_blue, forState: .Normal)
        timeLeft = Config.phoneCodeResendInterval
        resendCodeButton.titleLabel?.text = "You can resend the code again in \n\(timeLeft) seconds"
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("refresh"), userInfo: nil, repeats: true)
    }
    
    // MARK: Timer callbacks
    
    func refresh() {
        timeLeft--
        
        UIView.setAnimationsEnabled(false)
        resendCodeButton.setTitle("You can resend the code again in \n\(timeLeft) seconds", forState:.Normal)
        UIView.setAnimationsEnabled(true)
        
        
        if timeLeft <= 0 {
            resendCodeButton.enabled = true
            resendCodeButton.backgroundColor =  Utils.Color(12, 146, 254)
            resendCodeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            resendCodeButton.setTitle("RESEND THE CODE", forState: .Normal)
            timer?.invalidate()
            timer = nil
        }
    }
    
    // MARK: UI callbacks
    
    @IBAction func resendCodeTap() {
        self.showWaitOverlay()
        
        APIManager.sharedInstance.restorePassword(phone!,
            successCallback: { () -> Void in
                self.removeAllOverlays()
                self.startTimer()
            }) { (json) -> Void in
                self.removeAllOverlays()
                Utils.showErrorForJSON(json)
        }
    }
    
    @IBAction func confirmTap()
    {
        
//        code = codeTextField.text
        
        if (!(code!.characters.count > 0)) {
            let av = UIAlertView(title: "Error",
                message: "Code shouldn't be empty",
                delegate: nil,
                cancelButtonTitle: "OK")
            av.show()
            
            return
        }
        
        self.showWaitOverlay()
        continueButton.enabled = false
        
        if isChangingPhone
        {
            //confirmPhone
            APIManager.sharedInstance.confirmPhone(code!,
                successCallback: { (json) -> Void in
                    self.removeAllOverlays()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    self.continueButton.enabled = true
                }) { (json) -> Void in
                    self.codeTextField.text = ""
                    self.removeAllOverlays()
                    self.continueButton.enabled = true
                    self.continueButton.hidden = true
                    if let code = json?["code"] as? String
                    {
                        if code == "invalid_reset_code"
                        {
                            UIAlertView(title: "You entered a wrong code", message: "", delegate: nil, cancelButtonTitle: "OK").show()
                        }
                        else
                        {
                            Utils.showErrorForJSON(json)
                        }
                    }
            }
        }
        else
        {
            APIManager.sharedInstance.restorePasswordCheckCode(phone!,
                code: code!,
                successCallback: { () -> Void in
                    self.removeAllOverlays()
                    self.continueButton.enabled = true
                    self.performSegueWithIdentifier("new password", sender: self)
                }) { (json) -> Void in
                    self.codeTextField.text = ""
                    self.removeAllOverlays()
                    self.continueButton.enabled = true
                    self.continueButton.hidden = true
                    if let code = json?["code"] as? String
                    {
                        if code == "invalid_reset_code"
                        {
                            UIAlertView(title: "You entered a wrong code", message: "", delegate: nil, cancelButtonTitle: "OK").show()
                        }
                        else
                        {
                            Utils.showErrorForJSON(json)
                        }
                    }
            }
        }
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let length = newString.characters.count
        
        if  length > Config.phoneCodeLength {
            return false
        } else if length == Config.phoneCodeLength {
            code = newString
            self.confirmTap()
        }
        else
        {
            self.continueButton.hidden = true
        }
        
        return true
    }
}
