//
//  RestorePasswordVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 20/04/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class NewPasswordVC: ConnectionAwareVC {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    var phone: String?
    var code: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "NEW PASSWORD"
        
        self.addBackgroundRecognizer()
        
        continueButton.backgroundColor = Utils.Color(220, 220, 220)
        continueButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        continueButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: passwordTextField)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textChanged(textField: UITextField)
    {
        if (passwordTextField.text?.characters.count >= 6)
        {
            continueButton.backgroundColor = Utils.Color(12, 146, 254)
            continueButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            continueButton.enabled = true
        }
        else
        {
            continueButton.backgroundColor = Utils.Color(220, 220, 220)
            continueButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            continueButton.enabled = false
        }
        
    }
    
    // MARK: UI callbacks
    
    @IBAction func confirmTap() {
        let password = passwordTextField.text
        
        if (password?.characters.count < Config.minPasswordLength) {
            let av = UIAlertView(title: "Error",
                message: "Password should be at least \(Config.minPasswordLength) characters",
                delegate: nil,
                cancelButtonTitle: "OK")
            av.show()
            
            return;
        }
        
        self.showWaitOverlay()
        
        APIManager.sharedInstance.restorePasswordConfirm(phone!,
            code: code!,
            password: password,
            successCallback: { () -> Void in
                self.removeAllOverlays()
                self.dismissViewControllerAnimated(true, completion: nil)
        }) { (json) -> Void in
            self.removeAllOverlays()
            Utils.showErrorForJSON(json)
        }
    }
}
