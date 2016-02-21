//
//  BindCardVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 18/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation
import UIKit

class BindCardVC: ConnectionAwareVC, CardIOPaymentViewControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var cardNumberTextField: UITextField!
    
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var expirationTextField: BKCardExpiryField!
    @IBOutlet weak var expirationBorderView: UIView!
    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var doneButton: RoundedCornerButton!
    let expirationSeparator = " / "
    
    var paymentMethodToEdit: BraintreePaymentMethodModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        if (paymentMethodToEdit == nil) {
            CardIOUtilities.preload()
        } else {
            scanButton.hidden = true
            
            cardNumberTextField.text = paymentMethodToEdit!.maskedNumber!
            cardNumberTextField.userInteractionEnabled = false
            
            let month =  Int(paymentMethodToEdit!.expirationMonth!)! % 100
            let year = Int(paymentMethodToEdit!.expirationYear!)! % 100

            let monthFormatted = String(format: "%.2i", month)
            let yearFormatted = String(format: "%.2i", year)
            
            expirationTextField.text = monthFormatted + expirationSeparator + yearFormatted
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    // MARK: Other
    
    func finalizeCardBinding(token: String) {
        APIManager.sharedInstance.bindCard(token,
            successCallback: { (json) -> Void in
                self.removeAllOverlays()
                self.dismissViewControllerAnimated(true, completion: nil)
            }, failedCallback: { (json) -> Void in
                self.removeAllOverlays()
                Utils.showErrorForJSON(json)
        })
    }
    
    // MARK: CardIOPaymentViewControllerDelegate
    
    func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        paymentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func userDidProvideCreditCardInfo(cardInfo: CardIOCreditCardInfo!, inPaymentViewController paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            if info.cardNumber != nil {
                cardNumberTextField.text = info.cardNumber
            }
            
            if info.expiryMonth != 0 &&
                info.expiryYear != 0
            {
                let month = String(format: "%.2i", info.expiryMonth)
                
                expirationTextField.text = month + expirationSeparator + "\(info.expiryYear % 100)"
            }
            
            if info.cvv != nil {
                verificationCodeTextField.text = info.cvv
            }
        }
        paymentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UI callbacks
    
    @IBAction func scanCard(sender: AnyObject) {
        var cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC.modalPresentationStyle = .FormSheet
        presentViewController(cardIOVC, animated: true, completion: nil)
    }
    
    @IBAction func closeTap() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveThisCardTap() {
        
        if !reachability.isReachable()
        {
            return
        }
        
        doneButton.enabled = false
        
        
        let cardNumber = cardNumberTextField.text
        let verificationValue = verificationCodeTextField.text
        
        let month = "\(expirationTextField.dateComponents.month)"
        var year = "\(expirationTextField.dateComponents.year)"
        
        // Check number only if binding new card
        if paymentMethodToEdit == nil {
            if (!((cardNumber?.characters.count >= Config.minCardNumberLength) && (cardNumber?.characters.count <= Config.maxCardNumberLength))) {
                let av = UIAlertView(title: "Error",
                    message: "Card number length should be between \(Config.minCardNumberLength) and \(Config.maxCardNumberLength) characters",
                    delegate: nil,
                    cancelButtonTitle: "OK")
                av.show()
                
                doneButton.enabled = true
                
                return;
            }
        }
        
        if (verificationValue == nil || verificationValue?.characters.count == 0) {
            let av = UIAlertView(title: "Error",
                message: "CVV/CVC should not be empty",
                delegate: nil,
                cancelButtonTitle: "OK")
            av.show()
            
            doneButton.enabled = true
            
            return
        }
        
        if (!( (Int(month) >= 1) && (Int(month) <= 12)) ) {
            let av = UIAlertView(title: "Error",
                message: "Expiration month should be between 1 and 12",
                delegate: nil,
                cancelButtonTitle: "OK")
            av.show()
            
            doneButton.enabled = true
            
            return
        }
        
        if (!( year.characters.count == 2 || year.characters.count == 4) ) {
            let av = UIAlertView(title: "Error",
                message: "Expiration year should be 2 characters",
                delegate: nil,
                cancelButtonTitle: "OK")
            av.show()
            
            doneButton.enabled = true
            
            return
        }
        
        if year.characters.count == 2 {
            year = "20" + year
        }
        
        weak var wSelf = self
        
        self.showWaitOverlay()

        if paymentMethodToEdit == nil {
            APIManager.sharedInstance.bindCardBraintree(
                cardNumber!,
                verificationValue!,
                month,
                year,
                successCallback: { (token) in self.finalizeCardBinding(token) },
                failedCallback: { (json) in
                    self.removeAllOverlays()
                    self.doneButton.enabled = true
                    Utils.showErrorForJSON(json)
            })
        } else {
            APIManager.sharedInstance.updateCard(paymentMethodToEdit!.token!,
                expMonth: month,
                expYear: year,
                verificationValue: verificationValue!,
                successCallback: { (json) -> Void in
                    self.removeAllOverlays()
                    self.doneButton.enabled = true
                    if json != nil {
                        AuthManager.sharedInstance.removePaymentMethod(self.paymentMethodToEdit!)
                        AuthManager.sharedInstance.addPaymentMethod(json!)
                    }
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
            }, failedCallback: { (json) -> Void in
                self.removeAllOverlays()
                self.doneButton.enabled = true
                Utils.showErrorForJSON(json)
            })
        }
    }
    
    // MARK: UITextFieldDelegate

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }

    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        return true
    }
}
