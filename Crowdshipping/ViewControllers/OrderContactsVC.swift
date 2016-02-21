//
//  OrderContactsVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 24/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation

class OrderContactsVC : ConnectionAwareVC, UITextFieldDelegate, DropdownPhoneTFDelegate {
    @IBOutlet weak var senderPhoneTextField: DropdownPhoneTF!
    @IBOutlet weak var recipientPhoneTextField: DropdownPhoneTF!
    @IBOutlet weak var notesTextView: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var fromDetailsLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var toDetailsLabel: UILabel!
    
    @IBOutlet weak var scrollViewBottomOffset: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var fromDetailsHeight: NSLayoutConstraint!
    @IBOutlet weak var toDetailsHeight: NSLayoutConstraint!
    
    var keyboardToolbar: KeyboardToolbar?
    let nextButtonHeight = CGFloat(108)
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addBackgroundRecognizer()
        
        senderPhoneTextField.parentViewController = self
        recipientPhoneTextField.parentViewController = self
        
        keyboardToolbar = KeyboardToolbar(parentView: self.view)
        
        recipientPhoneTextField.setAccessoryView(keyboardToolbar)
        senderPhoneTextField.setAccessoryView(keyboardToolbar)

        recipientPhoneTextField.delegate = self
        senderPhoneTextField.delegate = self
        
        notesTextView.inputAccessoryView = keyboardToolbar
        
        nextButton.titleLabel?.textAlignment = .Center
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set info from current order
        let order = OrderManager.sharedInstance.currentOrder
        
        // Pickup phone
        if order.pickupPhone != nil {
            senderPhoneTextField.setPhone(order.pickupPhone!)
        } else if let phone = AuthManager.sharedInstance.getPhone() {
            senderPhoneTextField.setPhone(phone)
        }
        
        // Destination phone
        if order.destinationPhone != nil {
            recipientPhoneTextField.setPhone(order.destinationPhone!)
        }
        
        // Comments
        if order.notes != nil {
            notesTextView.text = order.notes!
        }
        
        // Pickup address
        fromAddressLabel.text = order.pickupAddress
        
        fromDetailsLabel.hidden = true
        fromDetailsHeight.constant = 0
        if let details = order.pickupAddressDetail {
            if details.characters.count > 0 {
                fromDetailsLabel.text = details
                fromDetailsLabel.hidden = false
                
                fromDetailsHeight.constant = 45
            }
        }
        
        // Delivery address
        toAddressLabel.text = order.destinationAddress

        toDetailsHeight.constant = 0
        toDetailsLabel.hidden = true
        if let details = order.destinationAddressDetail {
            if details.characters.count > 0 {
                toDetailsLabel.text = details
                toDetailsLabel.hidden = false
                
                toDetailsHeight.constant = 45
            }
        }
        
        checkIfFormIsValid()
        
        view.layoutSubviews()
    }
    
    // MARK: Other
    
    func checkIfFormIsValid() {
        if !senderPhoneTextField.isValid() || !recipientPhoneTextField.isValid() {
            nextButton.enabled = false
            nextButton.backgroundColor = UIColor.lightGrayColor()
        } else {
            nextButton.enabled = true
            nextButton.backgroundColor = Config.Visuals.color_blueButton
        }
    }
    
    // MARK: Notifications
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            
            var contentInsets = UIEdgeInsetsZero
            
            if keyboardSize.height > 0
            {
                contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + keyboardToolbar!.frame.size.height - nextButtonHeight, right: 0)
            }

            scrollView.contentInset = contentInsets
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.contentInset = contentInsets
    }
    
    // MARK: UI callbacks
    @IBAction func extraTapAreaTapped(sender: AnyObject) {
        notesTextView.becomeFirstResponder()
    }
    
    @IBAction func proceedTap() {        
        if (!senderPhoneTextField.isValid()) {
            let av = UIAlertView(title: "Error", message: "Sender's phone is not valid", delegate: nil, cancelButtonTitle: "OK")
            av.show()
            return
        }
        
        if (!recipientPhoneTextField.isValid()) {
            let av = UIAlertView(title: "Error", message: "Recipient's phone is not valid", delegate: nil, cancelButtonTitle: "OK")
            av.show()
            return
        }
        
        let order = OrderManager.sharedInstance.currentOrder
        
        order.pickupPhone = senderPhoneTextField.getPhone()
        order.destinationPhone = recipientPhoneTextField.getPhone()
        order.notes = notesTextView.text
        
        self.performSegueWithIdentifier("confirm", sender: self)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //scrollView.scrollRectToVisible(textField.frame, animated: true)
    }
    
    // MARK: DropdownPhoneTFDelegate
    func dropdownPhoneTFDidChangeValue(field: DropdownPhoneTF) {
        checkIfFormIsValid()
    }
}