//
//  ConfirmVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 16/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit
import MessageUI

class CurrentOrderVC: ConnectionAwareVC, UIAlertViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, UIGestureRecognizerDelegate, OrderCommentsVCDelegate {
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var viewWithStatusInfo: TopBottomBorderView!
    @IBOutlet var googleMapView: GMSMapView!
    @IBOutlet weak var menuButton: MenuButton?
    @IBOutlet weak var courierPhotoIV: UIImageView!
    @IBOutlet weak var courierTextLabel: UILabel!
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    @IBOutlet weak var courierViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var cancelButtonViewHeight: NSLayoutConstraint!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet var senderTapGesture: UITapGestureRecognizer!
    @IBOutlet var reciepentTapGesture: UITapGestureRecognizer!
    
    var simpleAlert: UIAlertView?
    var complexAlert: UIAlertView?
    var courierCancelAlert: UIAlertView?
    var adminCancelAlert: UIAlertView?
    var cancelAlert: UIAlertView?
    
    var contactCourierActionSheet: UIActionSheet?
    var cancelOrderActionSheet: UIActionSheet?
    
    
    // OrderAdditionalInfo
    @IBOutlet var orderAdditionalInfo: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var sendersPhoneLabel: UILabel!
    @IBOutlet weak var recipientsPhoneLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    @IBOutlet weak var commentImageIcon: UIImageView!
    // Confirmation codes
    @IBOutlet weak var confirmationCodeView: UIView!
    @IBOutlet weak var confirmationCodeViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topConfirmationLabel: UILabel!
    @IBOutlet weak var bottomConfirmationLabel: UILabel!
    
    @IBOutlet weak var scrollViewTopPadding: NSLayoutConstraint!
    var isAnimatingInfo = false
    
    
    var fromMarker: GMSMarker?
    var toMarker: GMSMarker?
    var courierMarker: GMSMarker?
    
    var order: OrderModel?
    var didCameFromHistory: Bool = false
    
    var isCourierCancelAlertShown: Bool = false
    var isAdminCancelAlertShown: Bool = false
    var isCancelAlertShown: Bool = false
    
     var isCancelByUser: Bool = false
    
    var timer: NSTimer?
    // time spent timer 
    var timeSpentTimer: NSTimer?
//    var spentTime = NSDate();
    
    let cancelableStates: [OrderModel.OrderState] = [.New, .CourierCancelled]
    
    var couriers = Array<CourierTrackModel>()
    var courierPins = Array<GMSMarker>()
    var courierTimer: NSTimer?
    
    var refreshControl: UIRefreshControl?
    
    deinit {
        NotificationManager.removeObserver(self)
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.layer.borderColor = UIColor.redColor().CGColor
        cancelButton.layer.borderWidth = 1.0
        
        self.googleMapView.settings.rotateGestures = false
        self.googleMapView.settings.tiltGestures = false
        self.googleMapView.settings.scrollGestures = false
        self.googleMapView.settings.zoomGestures = false
        
        self.googleMapView.settings.setAllGesturesEnabled(false)
        
        self.googleMapView.settings.consumesGesturesInView = true
        
        self.googleMapView.userInteractionEnabled = false
        
        if didCameFromHistory
        {
            self.cancelButton.hidden = true
            cancelButtonViewHeight.constant = 0
            self.scrollView.layoutSubviews()
            
            scrollViewTopPadding.constant = 300
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
        else
        {
            refreshControl = UIRefreshControl()
            refreshControl?.addTarget(self, action: Selector("refresh"), forControlEvents: .ValueChanged)
            scrollView.addSubview(refreshControl!)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print(touches)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if didCameFromHistory
        {
            self.cancelButton.hidden = true
            cancelButtonViewHeight.constant = 0
            self.scrollView.layoutSubviews()
        }
        
        self.courierPhotoIV.layer.cornerRadius = self.courierPhotoIV.frame.size.width/2
        self.courierPhotoIV.layer.masksToBounds = true
        self.courierPhotoIV.layer.borderWidth = 0;
        
        updateText()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).leftMenu.reloadHeader()
        
        if didCameFromHistory {
            
            self.title = "Order details"
            
            menuButton!.removeFromSuperview()
            menuButton = nil
            
            let backButton = UIBarButtonItem(image: UIImage(named: "BackButton"), style: .Plain, target: self, action: Selector("backTap"))
            self.navigationItem.leftBarButtonItem = backButton
            
            self.navigationItem.rightBarButtonItem = nil
            
            
        } else {
            menuButton!.delegate = self
            menuButton!.presentingViewController = self.navigationController
            
            NotificationManager.addObserver(self, selector: Selector("orderStatusChanged:"), name: .OrderStatusChanged)
            
            timer = NSTimer.scheduledTimerWithTimeInterval(Config.currentOrderRefreshInterval, target: self, selector: Selector("refresh"), userInfo: nil, repeats: true)
            
        }
        
        checkOrderState()
        fetchCourierInfo()
        updateMap()
        
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        (UIApplication.sharedApplication().delegate as! AppDelegate).leftMenu.reloadHeader()
        NotificationManager.removeObserver(self)
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: notifications
    
    func orderStatusChanged(notification: NSNotification) {
        if notification.object == nil {
            refresh()
        } else {
            order?.state = OrderModel.OrderState(rawValue: notification.object as! String)
            
//            order = (notification.object as OrderModel)
            
            updateText()
            updateMap()
            checkOrderState()
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func senderPhoneClicked(sender: AnyObject) {
        Utils.callPhoneNumber(sendersPhoneLabel.text!)
    }
    @IBAction func recipientPhoneClicked(sender: AnyObject) {
        Utils.callPhoneNumber(recipientsPhoneLabel.text!)
    }
    // MARK: other
    
    func checkOrderState() {
        if let state = order!.state {
            switch state {
            case .Delivery:
                if (self.timeSpentTimer == nil)
                {
//                    self.timeSpentTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
//                    spentTime = NSDate();
                }
            default:
                break
            }
        }
        if !didCameFromHistory
        {
            self.cancelButton.hidden = false
            cancelButtonViewHeight.constant = 108
            self.scrollView.layoutSubviews()
        }
        
        
        if let startDate = order!.timerStarted as NSDate!
        {
            if let endDate = order!.timerFinished as NSDate!
            {
                calculateDeliveryTime(startDate, finishDate: endDate)
            }
            else
            {
                calculateDeliveryTime(startDate, finishDate: NSDate())
            }
        }
        
        if let state = order!.state {
            switch state {
                case .AdminCancelled:
                    self.handleAdminCancellation()
                    self.timeSpentTimer?.invalidate()
                    self.timeSpentTimer = nil
                case .CourierCancelled:
                    self.handleCourierCancellation()
                    self.timeSpentTimer?.invalidate()
                    self.timeSpentTimer = nil
                case .Completed:
                    self.updateCancelButton()
                    self.navigationItem.rightBarButtonItem = nil
                    OrderManager.sharedInstance.deleteSavedOrder()
                    self.timeSpentTimer?.invalidate()
                    self.timeSpentTimer = nil
                    if courierMarker != nil {
                        courierMarker!.map = nil
                        courierMarker = nil
                    }
                    // AWESOME GOVNOCODE
                    let mainController = (UIApplication.sharedApplication().delegate as! AppDelegate).mainMapNavigation.viewControllers[0] as? MapVC
                    mainController?.shouldResetMap = true
                case .Cancelled:
                    self.updateCancelButton()
                    self.navigationItem.rightBarButtonItem = nil
                    OrderManager.sharedInstance.deleteSavedOrder()
                    self.timeSpentTimer?.invalidate()
                    self.timeSpentTimer = nil
                    if courierMarker != nil {
                        courierMarker!.map = nil
                        courierMarker = nil
                    }
                    if isCancelByUser
                    {
                        // AWESOME GOVNOCODE
                        let mainController = (UIApplication.sharedApplication().delegate as! AppDelegate).mainMapNavigation.viewControllers[0] as? MapVC
                        mainController?.shouldResetMap = true
                    }
                    else
                    {
                        self.showCancellationAlert()
                    }
            case .Delivery:
                self.cancelButton.hidden = true
                cancelButtonViewHeight.constant = 0
                self.scrollView.layoutSubviews()
            case .Accepted:
                break
            case .Returning:
                self.updateCancelButton()
                self.cancelButton.setTitle("CALL SUPPORT", forState: .Normal)
            case .Returned, .InOffice:
                self.updateCancelButton()
            default:
                    break
                }
        }
        if didCameFromHistory
        {
            self.cancelButton.hidden = true
            cancelButtonViewHeight.constant = 0
            self.scrollView.layoutSubviews()
        }
    }
    
    func updateCancelButton()
    {
        self.cancelButton.hidden = false
        cancelButtonViewHeight.constant = 108
        self.cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.cancelButton.backgroundColor = Config.Visuals.color_blueButton
        self.cancelButton.setTitle("CLOSE", forState: .Normal)
        self.cancelButton.layer.borderColor = UIColor.clearColor().CGColor
        self.cancelButton.layer.borderWidth = 0.0
        if didCameFromHistory
        {
            self.cancelButton.hidden = true
            cancelButtonViewHeight.constant = 0
        }
        self.scrollView.layoutSubviews()
    }
    
    func updateTime()
    {
//        let components = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: NSDate(), toDate: NSDate(), options: nil)
//        let hour = components.hour
//        let minutes = components.minute
//        
//        var hourString = String(hour)
//        var minuteString = String(minutes)
//        if (minutes < 10)
//        {
//            minuteString = String("0\(minutes)")
//        }
//        
//        self.timerLabel.text = String("\(hourString):\(minuteString)")
    }
    
    func calculateDeliveryTime(startTime: NSDate?, finishDate: NSDate?)
    {
        let components = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate:startTime!, toDate: finishDate!, options: [])
        let hour = components.hour
        let minutes = components.minute
        
        var hourString = String(hour)
        var minuteString = String(minutes)
        if (minutes < 10)
        {
            minuteString = String("0\(minutes)")
        }
        
        self.timerLabel.text = String("\(hourString):\(minuteString)")
    }
    
    func updateText() {
        var text = "At any time up until your order is accepted by a courier, you can cancel it without any fees.\n"
        
        self.timerLabel.hidden = false
        
        if let state = order!.state {
            switch state {
            case .New:
                statusLabel.text = "ASSIGNING"
                self.timerLabel.textColor = Utils.Color(95, 95, 95)
                statusLabel.textColor = Utils.Color(95, 95, 95)
            case .Cancelled:
                statusLabel.text = "CANCELLED"
                self.timerLabel.textColor = UIColor.redColor()
                statusLabel.textColor = UIColor.redColor()
            case .Accepted:
                statusLabel.text = "ASSIGNED"
                self.timerLabel.textColor = Utils.Color(255, 174, 84)
                statusLabel.textColor = Utils.Color(255, 174, 84)
            case .Delivery:
                statusLabel.text = "IN PROGRESS"
                self.timerLabel.textColor = Utils.Color(45, 160, 254)
                statusLabel.textColor = Utils.Color(45, 160, 254)
            case .Completed:
                statusLabel.text = "DELIVERED"
                self.timerLabel.textColor = Utils.Color(37, 220, 106)
                statusLabel.textColor = Utils.Color(37, 220, 106)
            case .CourierCancelled:
                self.timerLabel.hidden = true
                statusLabel.text = "COURIER CANCELLED"
                self.timerLabel.textColor = UIColor.redColor()
                statusLabel.textColor = UIColor.redColor()
            case .AdminCancelled:
                self.timerLabel.hidden = true
                statusLabel.text = "DELIVERY FAILURE"
                self.timerLabel.textColor = UIColor.redColor()
                statusLabel.textColor = UIColor.redColor()
            case .Returned:
                statusLabel.text = "RETURNED"
                self.timerLabel.textColor = Utils.Color(45, 160, 254)
                statusLabel.textColor = Utils.Color(45, 160, 254)
            case .Returning:
                statusLabel.text = "RETURNING"
                self.timerLabel.textColor = Utils.Color(45, 160, 254)
                statusLabel.textColor = Utils.Color(45, 160, 254)
            case .InOffice:
                statusLabel.text = "IN OFFICE"
                self.timerLabel.textColor = Utils.Color(45, 160, 254)
                statusLabel.textColor = Utils.Color(45, 160, 254)
            default:
                self.timerLabel.hidden = true
                statusLabel.text = "DELIVERY FAILURE"
                self.timerLabel.textColor = UIColor.redColor()
                statusLabel.textColor = UIColor.redColor()
                break
        }
        }
        
        fromLabel.text = nil
        if order!.pickupAddress != nil {
            fromLabel.text = order!.pickupAddress!
        }
        
        toLabel.text = nil
        if order!.destinationAddress != nil {
            toLabel.text = order!.destinationAddress!
        }
        
        if order!.pk != nil {
            self.title = "Order #\(order!.pk!)".uppercaseString
        }
        
        if order!.created != nil {
            text += ("Created: " + order!.created!.simpleFormat() + "\n")
        }
        

        confirmationCodeViewHeight.constant = 0
        confirmationCodeView.hidden = true
        
        topConfirmationLabel.textColor = UIColor.whiteColor()
        bottomConfirmationLabel.textColor = UIColor.whiteColor()
        
        if let state = order!.state
        {
            switch state {
                
                case .Accepted:
                if order!.pickupConfirmationCode != nil {
                    topConfirmationLabel.text = "Pick-up confirmation: ".uppercaseString + order!.pickupConfirmationCode!
                    bottomConfirmationLabel.text = "Please show it to the courier"
                    confirmationCodeViewHeight.constant = 90
                    
                    confirmationCodeView.backgroundColor = Config.Visuals.color_blue
                    confirmationCodeView.hidden = false
                }
                
                case .Delivery:
                    
                    if order!.deliveryConfirmationCode != nil {
                        if order!.state != nil && [.Delivery].contains(order!.state!) {
                            topConfirmationLabel.text = "Delivery confirmation: ".uppercaseString + order!.deliveryConfirmationCode!
                            bottomConfirmationLabel.text = "This code was sent to recipient by SMS"
                            confirmationCodeViewHeight.constant = 90
                            
                            confirmationCodeView.backgroundColor = Config.Visuals.color_green
                            confirmationCodeView.hidden = false
                        }
                }
            case .Returning:
                    if order!.deliveryConfirmationCode != nil {
                        if order!.state != nil && [.Returning].contains(order!.state!) {
                            topConfirmationLabel.text = "Return confirmation: ".uppercaseString + order!.deliveryConfirmationCode!
                            bottomConfirmationLabel.text = "Please show it to courier to get the order"
                            confirmationCodeViewHeight.constant = 90
                            
                            confirmationCodeView.backgroundColor = Config.Visuals.color_green
                            confirmationCodeView.hidden = false
                        }
                }
            default:
                break
            }
        }
        
//        if order!.pickupConfirmationCode != nil {
//            topConfirmationLabel.text = "Pick-up confirmation: ".uppercaseString + order!.pickupConfirmationCode!
//            bottomConfirmationLabel.text = "Please show it to the courier"
//            confirmationCodeViewHeight.constant = 90
//            
//            confirmationCodeView.backgroundColor = Config.Visuals.color_blue
//            confirmationCodeView.hidden = false
//        }
//        
//        if order!.deliveryConfirmationCode != nil {
//            if order!.state != nil && contains([.Delivery], order!.state!) {
//                topConfirmationLabel.text = "Delivery confirmation: ".uppercaseString + order!.deliveryConfirmationCode!
//                bottomConfirmationLabel.text = "This code was sent to recipient by SMS"
//                confirmationCodeViewHeight.constant = 90
//                
//                confirmationCodeView.backgroundColor = Config.Visuals.color_green
//                confirmationCodeView.hidden = false
//            }
//        }
        
        if let state = order!.state {
            switch state {
            case .New, .Completed, .Cancelled, .CourierCancelled, .AdminCancelled:
                confirmationCodeViewHeight.constant = 0
                confirmationCodeView.hidden = true
            case .Returning:
                if order!.returnDestination == "OFFICE"
                {
                    //Courier can not contact you
                    topConfirmationLabel.text = "Courier can't contact you"
                    bottomConfirmationLabel.text = "Courier will deliver order #" + order!.deliveryConfirmationCode! + " to our office"
                    confirmationCodeViewHeight.constant = 90
                    
                    topConfirmationLabel.textColor = Utils.Color(95, 95, 95)
                    bottomConfirmationLabel.textColor = Utils.Color(95, 95, 95)
                    confirmationCodeView.backgroundColor = Utils.Color(255, 255, 218)
                    confirmationCodeView.hidden = false
                }
            case .InOffice:
                topConfirmationLabel.text = "Order # " + order!.deliveryConfirmationCode! + " was delivered to office"
                if let text = order?.resolutionNote
                {
                    bottomConfirmationLabel.text = text
                }
                else
                {
                    bottomConfirmationLabel.text = "Courier is olen"
                }
                confirmationCodeViewHeight.constant = 90
                
                topConfirmationLabel.textColor = Utils.Color(95, 95, 95)
                bottomConfirmationLabel.textColor = Utils.Color(95, 95, 95)
                confirmationCodeView.backgroundColor = Utils.Color(255, 255, 218)
                confirmationCodeView.hidden = false
            case .Returned:
                confirmationCodeViewHeight.constant = 0
                confirmationCodeView.hidden = true
            default:
                break
            }
        }
        
        courierViewHeight.constant = 0
        self.courierPhotoIV.hidden = true
        courierTextLabel.hidden = true
        if let courier = order!.courier {
            courierViewHeight.constant = 90
            self.courierPhotoIV.hidden = false
            courierTextLabel.hidden = false
            
            var courierText = ""
            
            if courier.firstName != nil {
                courierText += "\(courier.firstName!) "
            }
            
            if courier.lastName != nil {
                courierText += "\(courier.lastName!)"
            }
            
            courierTextLabel.text = courierText
            self.courierPhotoIV.hidden = false
            
            if courier.photo != nil && courier.photo != "" {
                // TODO: replace with SDWebImage
                
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), { () -> Void in
                    if let url = NSURL(string: courier.photo!) {
                        if let data = NSData(contentsOfURL: url) {
                            let image = UIImage(data: data)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.courierPhotoIV.image = image
                            })
                        }
                    }
                })
            }
        }

        self.scrollView.layoutSubviews()
        
        self.view.layoutIfNeeded()
        
        //detailsLabel?.text = text
    }
    
    func updateMap() {
        var bounds = GMSCoordinateBounds()
        
        if order!.pickupPosition != nil {
            if fromMarker != nil {
                fromMarker!.map = nil
                fromMarker = nil
            }
            
            fromMarker = GMSMarker(position: order!.pickupPosition!)
            fromMarker!.map = self.googleMapView;
            fromMarker!.icon = UIImage(named: "PinFrom")
            fromMarker!.groundAnchor = CGPoint(x: 0.5, y: 1)
            
            bounds = bounds.includingCoordinate(order!.pickupPosition!)
        }
        
        if order!.destinationPosition != nil {
            if toMarker != nil {
                toMarker!.map = nil
                toMarker = nil
            }
            
            if let state = order!.state
            {
                if state != .Returning
                {
                    toMarker = GMSMarker(position: order!.destinationPosition!)
                    toMarker!.map = self.googleMapView;
                    toMarker!.icon = UIImage(named: "PinTo")
                    toMarker!.groundAnchor = CGPoint(x: 0.5, y: 1)
                    
                    bounds = bounds.includingCoordinate(order!.destinationPosition!)
                }
            }
            
        }
        
        if (order!.state == nil) || (order!.state! != .Completed) {
            if let courier = order!.courier {
                if let tail = courier.tail {
                    if tail.count != 0 {
                        var duration = Config.animationDurationCourier
                        
                        if courierMarker == nil {
                            var position = tail[0].coordinate!
                            
                            if tail.count >= 2 {
                                position = tail[1].coordinate!
                            }
                            
                            
                            let pin = GMSMarker(position: position)
                            pin!.map = self.googleMapView;
                            pin!.icon = UIImage(named: "PinCourierCurrent")
                            courierMarker = pin
                            
                            if tail.count >= 2 {
                                duration = tail[0].timestamp!.timeIntervalSinceDate(tail[1].timestamp!)
                            }
                        }
                        
                        
                        CATransaction.begin()
                        CATransaction.setAnimationDuration(duration)
                        courierMarker!.position = tail[0].coordinate!
                        
                        bounds = bounds.includingCoordinate(courierMarker!.position)
                        
                        CATransaction.commit()
                    }
                }
            }
        }
        
        let update = GMSCameraUpdate.fitBounds(bounds, withEdgeInsets: UIEdgeInsets(top: 130, left: 20, bottom: 20, right: 20))
        googleMapView.animateWithCameraUpdate(update)
    }
    
    func refresh() {
        if !AuthManager.sharedInstance.isLoggedIn() {
            self.performSegueWithIdentifier("register", sender: self)
            return
        }

        weak var wSelf = self
        
        if let orderID = OrderManager.sharedInstance.currentOrder.pk
        {
            APIManager.sharedInstance.getOrderDetails(orderID,
                successCallback: { (arg) -> Void in
                    if let newOrder = Mapper<OrderModel>().map(arg) {
                        //Utils.log(newOrder)
                        self.order = newOrder
                        OrderManager.sharedInstance.currentOrder = newOrder
                        
                        self.updateText()
                        self.updateMap()
                        self.refreshControl?.endRefreshing()
                        self.checkOrderState()
                    }
                }) { (arg) -> Void in
                    self.refreshControl?.endRefreshing()
                    Utils.log(arg)
            }
        }
        
    }
    
    // MARK: UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        //Utils.log(buttonIndex)
        
        if actionSheet == contactCourierActionSheet
        {
            switch buttonIndex {
            case 1: // Call
                if let phone = order?.courier?.phone {
                    Utils.callPhoneNumber(phone)
                }
            case 2: // Send a message
                if let phone = order?.courier?.phone {
                    if MFMessageComposeViewController.canSendText() {
                        let mcvc = MFMessageComposeViewController()
                        mcvc.recipients = [phone]
                        mcvc.messageComposeDelegate = self
                        self.presentViewController(mcvc, animated: true, completion: nil)
                    }
                }
            default: // Close
                break
            }
        }
        else if actionSheet == cancelOrderActionSheet
        {
            
            var reason = ""
            
            switch buttonIndex {
            case 1:
                reason = "CHANGED_MIND"
            case 2:
                reason = "COURIER_DELAY"
            case 3:
                var comment = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("OrderCommentsVC") as! OrderCommentsVC
                comment.isOrderCancellation = true
                comment.delegate = self
                let nc = UINavigationController(rootViewController: comment)
                
                presentViewController(nc, animated: true, completion: nil)
                return
            default:
                break
            }
            
            cancelOrderWithReason(reason, note: nil)
        }
    }
    
    func orderCommentsVCDidFinish(controller:OrderCommentsVC, text:String)
    {
        cancelOrderWithReason("OTHER", note: text)
    }
    
    func cancelOrderWithReason(reason: String, note: String?)
    {
        self.showWaitOverlay()
        self.cancelButton.enabled = false
        
        let orderID = order!.pk!
        var parameters = ["reason": reason as String]
        if note != nil
        {
            parameters["note"] = note!
        }
        APIManager.sharedInstance.cancelOrder(orderID, parameters: parameters,
            successCallback: { (json) -> Void in
                self.cancelButton.enabled = true
                self.removeAllOverlays()
                
                OrderManager.sharedInstance.resetOrder()
                
                // !!!: delete file with current order
                OrderManager.sharedInstance.deleteSavedOrder()
                let mainController = (UIApplication.sharedApplication().delegate as! AppDelegate).mainMapNavigation.viewControllers[0] as? MapVC
                mainController?.shouldResetMap = true
                self.navigationController?.popToRootViewControllerAnimated(true)
            }, failedCallback: { (json) -> Void in
                self.removeAllOverlays()
                self.cancelButton.enabled = true
                Utils.showErrorForJSON(json)
                self.isCancelByUser = false
        })
    }
    
    // MARK: MFMessageComposeViewControllerDelegate
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UI callbacks
    @IBAction func courierTap() {
        if order?.courier?.phone != nil {
            contactCourierActionSheet = UIActionSheet(title: "Courier",
                delegate: self,
                cancelButtonTitle: "Cancel",
                destructiveButtonTitle: nil,
                otherButtonTitles: "Call", "Send a message")
            
            contactCourierActionSheet?.showInView(self.view)
        }
    }
    
    
    func backTap() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    // If order is cancelled/delivered
    func goBackTap() {
        OrderManager.sharedInstance.resetOrder()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }    
    
    @IBAction func refreshTap() {
        refresh()
    }
    
    @IBAction func cancelTap() {
        
        cancelButton.enabled = false
        
        if let state = order!.state
        {
            switch state{
            case .Completed, .Cancelled, .AdminCancelled, .Returned, .InOffice:
                let mainController = (UIApplication.sharedApplication().delegate as! AppDelegate).mainMapNavigation.viewControllers[0] as? MapVC
                mainController?.shouldResetMap = true
                OrderManager.sharedInstance.resetOrder()
                OrderManager.sharedInstance.deleteSavedOrder()
                self.navigationController?.popToRootViewControllerAnimated(true)
                return
            case .Returning:
                Utils.callPhoneNumber(Config.officePhone)
                return
            default:
                break
            }
            
            self.cancelButton.enabled = true
        }
        
        if !AuthManager.sharedInstance.isLoggedIn() {
            self.performSegueWithIdentifier("register", sender: self)
            self.cancelButton.enabled = true
            return
        }
        
        if let state = order!.state
        {
            
            isCancelByUser = true
            
            if cancelableStates.contains(state)
            {
                simpleAlert = UIAlertView(title:  "Are you sure you want to cancel this order?", message: "No courier is assigned to this order, cancel it", delegate: self, cancelButtonTitle: "Cancel this order", otherButtonTitles: "Do not cancel")
                simpleAlert?.show()
            }
            else
            {
                complexAlert = UIAlertView(title: "Are you sure you want to cancel this order?", message: "Courier has been assigned and coming to pick up your order. Don't cancel the order without a reason.", delegate: self, cancelButtonTitle: "Cancel this order", otherButtonTitles: "Do not cancel")
                complexAlert?.show()
            }
        }
    }
    
    @IBAction func infoTap() {
        if isAnimatingInfo {
            return
        }
        
        if orderAdditionalInfo != nil {
            self.isAnimatingInfo = true

            infoButton.selected = false
            
            UIView.animateWithDuration(Config.animationDurationDefault, animations: { () -> Void in
                self.orderAdditionalInfo.alpha = 0
            }, completion: { (finished) -> Void in
                self.orderAdditionalInfo = nil
                self.isAnimatingInfo = false
                self.scrollView.scrollEnabled = true
                
                self.senderTapGesture.delegate = nil
                self.reciepentTapGesture.delegate = nil
            })
        } else {
            NSBundle.mainBundle().loadNibNamed("OrderAdditionalInfo", owner: self, options: nil)
            
            infoButton.selected = true

            var frame = orderAdditionalInfo.frame
            
            frame.origin.y = 0
            frame.size.width = self.view.bounds.size.width
            orderAdditionalInfo.frame = frame
            orderAdditionalInfo.layoutSubviews()

            orderAdditionalInfo.alpha = 0
            self.scrollView.scrollEnabled = false
//            self.view.addSubview(self.orderAdditionalInfo)
            self.containerView.addSubview(self.orderAdditionalInfo)

            if order!.orderSize != nil {
                sizeLabel.text = order!.orderSize!.rawValue.lowercaseString.capitalizedString
            }
            
            if order!.price != nil {
                priceLabel.text = "\(Config.currency)\(order!.price!)"
            }
            
            if order!.pickupPhone != nil {
                sendersPhoneLabel.text = order!.pickupPhone!
            }
            
            if order!.destinationPhone != nil {
                recipientsPhoneLabel.text = order!.destinationPhone!
            }

            commentsLabel.text = order!.notes
            
            if order!.notes?.isEmpty == true
            {
                self.commentImageIcon.hidden = true
            }
            
            self.isAnimatingInfo = true

            UIView.animateWithDuration(Config.animationDurationDefault, animations: { () -> Void in
                self.orderAdditionalInfo.alpha = 1
            }, completion: { (finished) -> Void in
                self.isAnimatingInfo = false
                
                self.senderTapGesture.delegate = self
                self.reciepentTapGesture.delegate = self
            })
        }
    }
    
    // MARK: UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        
        if alertView == simpleAlert
        {
            if buttonIndex == 0 {
                self.cancelOrder()
            }
            else
            {
                isCancelByUser = false
            }
        }
        else if alertView == complexAlert
        {
            if buttonIndex == 0
            {
                cancelOrderActionSheet = UIActionSheet(title: "Select the reason for cancellation",
                    delegate: self,
                    cancelButtonTitle: "Cancel",
                    destructiveButtonTitle: nil,
                    otherButtonTitles: "Sorry, I have changed my mind", "Courier didn’t come on time", "Other")
                
                cancelOrderActionSheet?.showInView(self.view)
            }
            else
            {
                isCancelByUser = false
            }
        }
        else if alertView == courierCancelAlert
        {
            isCourierCancelAlertShown = false
            if buttonIndex == 0
            {
                let mainController = (UIApplication.sharedApplication().delegate as! AppDelegate).mainMapNavigation.viewControllers[0] as? MapVC
                mainController?.shouldResetMap = true
                self.cancelOrder()
            }
            else
            {
                self.republishOrder()
            }
        }
        else if alertView == adminCancelAlert
        {
            isAdminCancelAlertShown = false
            let mainController = (UIApplication.sharedApplication().delegate as! AppDelegate).mainMapNavigation.viewControllers[0] as? MapVC
            mainController?.shouldResetMap = true
            OrderManager.sharedInstance.resetOrder()
            OrderManager.sharedInstance.deleteSavedOrder()
//            self.navigationController?.popToRootViewControllerAnimated(true)
            if (buttonIndex == 1)
            {
                Utils.callPhoneNumber(Config.officePhone)
            }
            
        }
        else if alertView == cancelAlert
        {
            isCancelAlertShown = false
            let mainController = (UIApplication.sharedApplication().delegate as! AppDelegate).mainMapNavigation.viewControllers[0] as? MapVC
            mainController?.shouldResetMap = true
            OrderManager.sharedInstance.resetOrder()
            OrderManager.sharedInstance.deleteSavedOrder()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func cancelOrder()
    {
        
        
        self.cancelButton.enabled = false
        self.showWaitOverlay()
        
        let orderID = order!.pk!
        APIManager.sharedInstance.cancelOrder(orderID, parameters: nil,
            successCallback: { (json) -> Void in
                self.cancelButton.enabled = true
                self.removeAllOverlays()
                
                OrderManager.sharedInstance.resetOrder()
                
                // !!!: delete file with current order
                OrderManager.sharedInstance.deleteSavedOrder()
                let mainController = (UIApplication.sharedApplication().delegate as! AppDelegate).mainMapNavigation.viewControllers[0] as? MapVC
                mainController?.shouldResetMap = true
                self.navigationController?.popToRootViewControllerAnimated(true)
            }, failedCallback: { (json) -> Void in
                self.cancelButton.enabled = true
                self.removeAllOverlays()
                Utils.showErrorForJSON(json)
                self.isCancelByUser = false
        })
    }
    
    func republishOrder()
    {
        self.showWaitOverlay()
        
        let orderID = order!.pk!
        APIManager.sharedInstance.republishOrder(orderID,
            successCallback: { (json) -> Void in
                self.removeAllOverlays()
                self.refresh()
            }, failedCallback: { (json) -> Void in
                self.removeAllOverlays()
                Utils.showErrorForJSON(json)
        })
    }
    
    func handleCourierCancellation()
    {
        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        
        
        if !isCourierCancelAlertShown && !didCameFromHistory
        {
            
            if let cancellationReason = order?.courierCancelReason
            {
                
                if cancellationReason == "CANT_PICKUP"
                {
                    courierCancelAlert = UIAlertView(title: "Courier can't pick up your order", message: "You can republish your order, or, if it’s too late, cancel it.", delegate: self, cancelButtonTitle: "Cancel this order", otherButtonTitles: "Find another courier")
                }
                else
                {
                    courierCancelAlert = UIAlertView(title: "Courier will not come to pick up your order", message: "You can republish your order, or, if it’s too late, cancel it.", delegate: self, cancelButtonTitle: "Cancel this order", otherButtonTitles: "Repeat")
                }
                
            }
            else
            {
                courierCancelAlert = UIAlertView(title: "Courier will not come to pick up your order", message: "You can republish your order, or, if it’s too late, cancel it.", delegate: self, cancelButtonTitle: "Cancel this order", otherButtonTitles: "Repeat")
            }
            
            courierCancelAlert?.show()
            isCourierCancelAlertShown = true
            
        }
    }
    
    func handleAdminCancellation()
    {
        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        
        cancelButton.setTitle("CLOSE", forState: .Normal)
        confirmationCodeViewHeight.constant = 0
        confirmationCodeView.hidden = true
        self.scrollView.layoutSubviews()
        self.view.layoutIfNeeded()
        if !isAdminCancelAlertShown && !didCameFromHistory
        {
            adminCancelAlert = UIAlertView(title: "Something went wrong", message: "Please call to our support center", delegate: self, cancelButtonTitle: "Close", otherButtonTitles: "Call")
            adminCancelAlert?.show()
            isAdminCancelAlertShown = true
        }
    }
    
    func showCancellationAlert()
    {
        if !isCancelAlertShown && !didCameFromHistory
        {
            cancelAlert = UIAlertView(title: "Your order was cancelled", message: "Please create a new one", delegate: self, cancelButtonTitle: "Close")
            cancelAlert?.show()
            isCancelAlertShown = true
        }
    }
    
    func updateCouriers(newCouriers: [CourierTrackModel]) {
        
        for courier in couriers {
            if let updatedCourier = newCouriers.filter({courier.id == $0.id}).first {
                // Courier is present in updated array
                let position = updatedCourier.tail![0].coordinate!
                courier.pin!.map = self.googleMapView
                updatedCourier.pin = courier.pin!
                //updatedCourier.pin!.layer.removeAllAnimations()
                
                CATransaction.begin()
                CATransaction.setAnimationDuration(Config.animationDurationCourier)
                updatedCourier.pin!.position = position
                
                CATransaction.commit()
                
            } else {
                // Courier is NOT present in updated array - remove pin
                let pin = courier.pin
                pin!.map = nil
            }
        }
        
        for courier in newCouriers {
            // New couriers
            if courier.pin == nil {
                let tail = courier.tail!
                
                if tail.count != 0 {
                    var position = courier.tail![0].coordinate!
                    
                    if tail.count >= 2 {
                        position = courier.tail![1].coordinate!
                    }
                    
                    let pin = GMSMarker(position: position)
                    pin!.map = self.googleMapView
                    pin!.icon = UIImage(named: "PinCourier")
                    courier.pin = pin
                    
                    if tail.count >= 2 {
                        let duration = tail[0].timestamp!.timeIntervalSinceDate(tail[1].timestamp!)
                        
                        CATransaction.begin()
                        CATransaction.setAnimationDuration(duration)
                        pin!.position = courier.tail![0].coordinate!
                        
                        CATransaction.commit()
                    }
                }
            }
        }
        
        
        couriers = newCouriers
        
        if let state = order!.state {
            switch state {
            case .New:
                break
            default:
                for courier in couriers
                {
                    let pin = courier.pin
                    pin!.map = nil
                }
            }
        }
    }
    
    func fetchCourierInfo() {
        courierTimer?.invalidate()
        courierTimer = NSTimer.scheduledTimerWithTimeInterval(Config.animationDurationCourier, target: self, selector: Selector("fetchCourierInfo"), userInfo: nil, repeats: true)
        
        let visibleRegion = googleMapView!.projection.visibleRegion();
        let bounds = GMSCoordinateBounds(region: visibleRegion)
        
        let northEast = bounds.northEast
        let southWest = bounds.southWest
        
        APIManager.sharedInstance.getNearbyCouriers(northEast, southwest: southWest, successCallback:{ (arg) in
            //Utils.log(arg)
            self.courierTimer?.invalidate()
            self.courierTimer = NSTimer.scheduledTimerWithTimeInterval(Config.animationDurationCourier, target: self, selector: Selector("fetchCourierInfo"), userInfo: nil, repeats: true)
            
            self.updateCouriers(arg)
            }, failedCallback: { (arg) in
                Utils.showErrorForJSON(arg)
            }
        )
    }
}
