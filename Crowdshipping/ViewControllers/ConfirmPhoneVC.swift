//
//  ConfirmPhoneVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 23/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class ConfirmPhoneVC: ConnectionAwareVC, UITextFieldDelegate {
    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var resendCodeButton: UIButton!
    @IBOutlet var infoLabel: UILabel!
    
    var phone: String?
    
    var timer: NSTimer?
    let interval = NSTimeInterval(1)

    var timeLeft = Config.phoneCodeResendInterval
    
    var code: String?
    var addCloseButton = false
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addBackgroundRecognizer()
        
        startTimer()
        
        self.codeTextField.becomeFirstResponder()
        
        if phone != nil {
            infoLabel.text = "We have sent sms code to your phone\n\(phone!)"
        } else {
            infoLabel.text = "We have sent sms code to your phone"
        }
        
        if addCloseButton {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .Plain, target: self, action: Selector("closeTap"))
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Other
    
    func verify() {
        
        /*
        if !Utils.validateValue(code, validator: { (val) -> Bool in countElements(code) == Config.phoneCodeLength },
        errorMessage: "Code length should be \(Config.phoneCodeLength) characters")
        { return }
        */
        
        if (!(code!.characters.count == Config.phoneCodeLength)) {
            let av = UIAlertView(title: "Error",
                message: "Code length should be \(Config.phoneCodeLength) characters",
                delegate: nil,
                cancelButtonTitle: "OK")
            av.show()
            
            return
        }
        
        self.showWaitOverlay()
        
        APIManager.sharedInstance.confirmPhone(code!,
            successCallback: { (arg) -> Void in
                self.removeAllOverlays()
                
                if !AuthManager.sharedInstance.getHasPaymentMethod() {
                    self.performSegueWithIdentifier("bind card", sender: self)
                } else {
                    Utils.lastTimerValue = Config.phoneCodeResendInterval
                    (UIApplication.sharedApplication().delegate as! AppDelegate).leftMenu.reloadHeader()
                    self.self.dismissViewControllerAnimated(true, completion: nil)
                }
                
                DefaultsManager.set(self.phone!, forKey: .Phone)
                
            }) { (arg) -> Void in
                self.removeAllOverlays()
                
                let av = UIAlertView(title: "You've entered the wrong code",
                    message: "",
                    delegate: nil,
                    cancelButtonTitle: "OK")
                av.show()
        }
    }
    
    func startTimer() {
        
        Utils.startSMSTimer()
        
        resendCodeButton.hidden = true
        timeLeft = Utils.lastTimerValue
        
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("refresh"), userInfo: nil, repeats: true)
    }

    // MARK: Timer callbacks
    
    func refresh() {
        timeLeft--
        
        Utils.lastTimerValue = timeLeft
        
        if timeLeft <= 0 {
            Utils.lastTimerValue = Config.phoneCodeResendInterval
            resendCodeButton.hidden = false
            timer?.invalidate()
            timer = nil
        }
        timerLabel.text = "You can resend the code again in \n\(timeLeft) seconds"
    }
    
    // MARK: UI callbacks
    
    @IBAction func resendCodeTap() {
        self.showWaitOverlay()
        
        APIManager.sharedInstance.bindPhone(nil,
            successCallback: { (arg) -> Void in
                self.removeAllOverlays()
                
                self.startTimer()
            }) { (arg) -> Void in
                self.removeAllOverlays()
                
                Utils.showErrorForJSON(arg)
        }
    }
    
    @IBAction func closeTap() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let length = newString.characters.count
        
        if  length > Config.phoneCodeLength {
            return false
        } else if length == Config.phoneCodeLength {
            code = newString
            self.verify()
        }
        
        return true
    }

}
