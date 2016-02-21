//
//  ConfirmVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 16/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class ConfirmVC: ConnectionAwareVC, UIAlertViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var pickupInfoLabel: UILabel!
    @IBOutlet weak var deliveryInfoLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var expiredLabel: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cardLogoIV: UIImageView!    
    
    @IBOutlet weak var cardView: TopBottomBorderView!
    
    var currentPaymentMethod: BraintreePaymentMethodModel?
    var methods: [BraintreePaymentMethodModel] = []
    
    var expiredAlert: UIAlertView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmButton.titleLabel?.textAlignment = .Center
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Order info
        
        let order = OrderManager.sharedInstance.currentOrder
        
        sizeLabel.text = order.orderSize!.rawValue.lowercaseString.capitalizedString
        
        if order.price != nil {
            priceLabel.text = "\(Config.currency)\(order.price!)"
        }
        
        var pickupText = order.pickupAddress! + "\n"
        if let details = order.pickupAddressDetail {
            pickupText = (pickupText + details + "\n")
        }
        pickupText = pickupText + order.pickupPhone!
        pickupInfoLabel.text = pickupText
        
        var deliveryText = order.destinationAddress! + "\n"
        if let details = order.destinationAddressDetail {
            deliveryText = (deliveryText + details + "\n")
        }
        deliveryText = deliveryText + order.destinationPhone!
        deliveryInfoLabel.text = deliveryText
        
        cardLabel.text = nil
        if let method = AuthManager.sharedInstance.getDefaultPaymentMethod() {
            if method.maskedNumber != nil {
                cardLabel.text = "\(method.maskedNumber!)"
            }
            
            cardLogoIV.setIconForCard(method)
            
            currentPaymentMethod = method
            expiredLabel.hidden = !method.checkIfExpired()
            OrderManager.sharedInstance.currentOrder.paymentMethod = method.token
            
        }
        
        // Confirm/Sign in/Confirm phone
        
        if !AuthManager.sharedInstance.isLoggedIn() {
            confirmButton.setTitle("Sign in to complete your order", forState: .Normal)
            self.cardView.hidden = true
        } else if AuthManager.sharedInstance.shouldBindPhone() {
            confirmButton.setTitle("Please confirm your phone\nto complete your order", forState: .Normal)
            self.cardView.hidden = true
        } else {
            confirmButton.setTitle("CONFIRM", forState: .Normal)
            self.cardView.hidden = false
        }
        
        // MARK to hide payments
//        self.cardView.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "current order":
            (segue.destinationViewController as! CurrentOrderVC).order = OrderManager.sharedInstance.currentOrder
        /*case "register":
            ((segue.destinationViewController as UINavigationController).viewControllers[0] as RegisterVC).switchSkipButtonTitle = true*/
        case "confirm phone":
            ((segue.destinationViewController as! UINavigationController).viewControllers[0] as! ConfirmPhoneVC).addCloseButton = true
        default:
            break
        }
    }
    
    // MARK: UI callbacks
    
    @IBAction func commentsTap() {
        self.performSegueWithIdentifier("show comments", sender: self)
    }
    
    @IBAction func cardViewTapped(sender: AnyObject)
    {
        
//        let cards = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("ManageCardsVC") as ManageCardsVC
//        self.navigationController?.pushViewController(cards, animated:true)
//        
//        return
        
        var defaultMethod = AuthManager.sharedInstance.getDefaultPaymentMethod()
        methods = AuthManager.sharedInstance.getAllPaymentMethods()
        
        var actionSheet = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.title = "Choose another payment method"
        for method in methods
        {
            var buttonText = ""
            if method == defaultMethod
            {
                actionSheet.addButtonWithTitle("\(method.maskedNumber!) (Default)")
            }
            else
            {
                actionSheet.addButtonWithTitle("\(method.maskedNumber!)")
            }
        }
        actionSheet.cancelButtonIndex = actionSheet.addButtonWithTitle("Cancel")
        
        actionSheet.showInView(self.view)

    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int)
    {
        if buttonIndex < methods.count
        {
            var method = methods[buttonIndex]
            cardLabel.text = "\(method.maskedNumber!)"
            cardLogoIV.setIconForCard(method)
            
            currentPaymentMethod = method
            expiredLabel.hidden = !method.checkIfExpired()
            OrderManager.sharedInstance.currentOrder.paymentMethod = method.token
        }
    }
    
    @IBAction func proceedTap() {
        
        if currentPaymentMethod != nil && currentPaymentMethod!.checkIfExpired()
        {
            
            expiredAlert = UIAlertView(title: "Your card expired", message: "", delegate: self, cancelButtonTitle: "Select another one")
            expiredAlert!.show()
            
            return
        }
        
        confirmButton.enabled = false
        
        if !AuthManager.sharedInstance.isLoggedIn() {
            self.performSegueWithIdentifier("register", sender: self)
            
            confirmButton.enabled = true
            return
        }
        
        
        if AuthManager.sharedInstance.shouldBindPhone() {
            
            if Utils.isNextSMSAvaible()
            {
                self.showWaitOverlay()
                APIManager.sharedInstance.bindPhone(AuthManager.sharedInstance.getPhone()!,
                    successCallback: { (arg) -> Void in
                        self.removeAllOverlays()
                        
                        self.confirmButton.enabled = true
                        self.performSegueWithIdentifier("confirm phone", sender: self)
                    }) { (arg) -> Void in
                        self.removeAllOverlays()
                        self.confirmButton.enabled = true
                        Utils.showErrorForJSON(arg)
                }
            }
            else
            {
                self.performSegueWithIdentifier("confirm phone", sender: self)
            }
            
            self.confirmButton.enabled = true
            
            return
        }
        
        if !AuthManager.sharedInstance.getHasPaymentMethod() {
            self.performSegueWithIdentifier("bind card", sender: self)
            
            self.confirmButton.enabled = true
            return
        }
        
        self.showWaitOverlay()
        weak var wSelf = self
        
        APIManager.sharedInstance.makeOrder({ (json) -> Void in
            let newOrder = Mapper<OrderModel>().map(json)
            OrderManager.sharedInstance.currentOrder = newOrder!
            
            NSKeyedArchiver.archiveRootObject(newOrder!, toFile: Config.currentOrderFilePath)
            
            let sSelf = wSelf
            if sSelf != nil {
                self.confirmButton.enabled = true
                sSelf!.removeAllOverlays()
                
                self.performSegueWithIdentifier("current order", sender: self)
            }
        }, failedCallback: { (json) -> Void in
            let sSelf = wSelf
            if sSelf != nil {
                self.confirmButton.enabled = true
                sSelf!.removeAllOverlays()
                
                if let code = json?["code"] as? String {
                    if code == "active_order_exists"
                    {
                        let av = UIAlertView(title: "Active order already exists", message: "You will be taken to active order", delegate: self, cancelButtonTitle: "OK")
                        av.show()
                    }
                    else if ["no_payment_method", "payment_error"].contains(code)
                    {
                        Utils.showErrorForJSON(json)
                        self.performSegueWithIdentifier("bind card", sender: self)
                    }
                }
            }
        })
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int)
    {
        
        if alertView == expiredAlert
        {
            self.cardViewTapped("")
        }
        else
        {
            if (buttonIndex == 0){
                let mainController = (UIApplication.sharedApplication().delegate as! AppDelegate).mainMapNavigation.viewControllers[0] as? MapVC
                mainController?.shouldResetMap = true
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }

}
