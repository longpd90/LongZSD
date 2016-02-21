//
//  BindPhoneVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 23/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class BindPhoneVC: ConnectionAwareVC, PhoneCodeDelegate {
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var phoneCodeButton: UIButton!
    
    private var phoneCode = "+65"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        self.addBackgroundRecognizer()
        
        /*
        var prefixLabel = UILabel(frame: CGRectMake(0, 0, 20, phoneTextField.frame.size.height))
        prefixLabel.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
        prefixLabel.text = Config.phonePrefix
        prefixLabel.sizeToFit()
        phoneTextField.leftView = prefixLabel
        
        phoneTextField.leftViewMode = .Always
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UI callbacks
    
    @IBAction func nextStepTap() {
        let phone = phoneTextField.text
        
        // TODO: uncomment
        /*
        if !Utils.validateValue(phone, validator: { (val) -> Bool in countElements(phone) == Config.phoneLength },
            errorMessage: "Phone length should be \(Config.phoneLength) characters")
            { return }
        */
        
        self.showWaitOverlay()
        
        APIManager.sharedInstance.bindPhone(phoneCode + phone!,
            successCallback: { (arg) -> Void in
                self.removeAllOverlays()
                
                self.performSegueWithIdentifier("confirm phone", sender: self)
        }) { (arg) -> Void in
            self.removeAllOverlays()
            
            Utils.showErrorForJSON(arg)
        }
    }
    
    @IBAction func phoneCodeTap() {
        let pcvc = PhoneCodeVC()
        pcvc.delegate = self
        
        let nc = UINavigationController(rootViewController: pcvc)
        self.presentViewController(nc, animated: true) { () -> Void in }
    }
    
    // MARK: PhoneCodeDelegate
    
    @objc func setPhoneCode(code: String) {
        phoneCode = "+" + code
        phoneCodeButton.setTitle(phoneCode, forState: .Normal)
    }
}
