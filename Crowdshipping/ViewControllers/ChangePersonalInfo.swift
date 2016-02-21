//
//  ChangePersonalInfo.swift
//  Crowdshipping
//
//  Created by Ivan Kozlov on 22/06/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

class ChangePersonalInfo: ConnectionAwareVC, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addBackgroundRecognizer()
        
        firstNameTextField.delegate = self
        lastnameTextField.delegate = self
        
        continueButton.backgroundColor = Utils.Color(220, 220, 220)
        continueButton.enabled = false
        
        firstNameTextField.text = AuthManager.sharedInstance.userProfile?.firstName
        lastnameTextField.text = AuthManager.sharedInstance.userProfile?.lastName
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: firstNameTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: lastnameTextField)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textChanged(textField: UITextField)
    {
        if (!firstNameTextField.text!.isEmpty &&
            !lastnameTextField.text!.isEmpty)
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
        
        if textField == firstNameTextField
        {
            lastnameTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    @IBAction func confirmTap() {
        
        continueButton.enabled = false
        self.showWaitOverlay()
        
        let firstName = firstNameTextField.text
        let lastName = lastnameTextField.text
        
        APIManager.sharedInstance.changePersonalInfo(firstName!,
            lastName: lastName!,
            successCallback: { () -> Void in
                self.continueButton.enabled = true
                self.removeAllOverlays()
                
                AuthManager.sharedInstance.userProfile?.firstName = firstName
                AuthManager.sharedInstance.userProfile?.lastName = lastName
                
                self.navigationController?.popToRootViewControllerAnimated(true)
            }) { (json) -> Void in
                self.continueButton.enabled = true
                self.removeAllOverlays()
                Utils.showErrorForJSON(json)
        }
    }
}
