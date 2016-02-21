//
//  APNSManager.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 25/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation

class APNSManager {
    class var sharedInstance : APNSManager {
        struct Static {
            static let instance : APNSManager = APNSManager()
        }
        return Static.instance
    }
    
    func register() {
        let application = UIApplication.sharedApplication()
        
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let setting = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(setting);
            application.registerForRemoteNotifications();
        } else {
            application.registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        }
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData!) {
        Utils.log("Got token data! \(deviceToken)")
        
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for var i = 0; i < deviceToken.length; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        if tokenString.characters.count != 0 {
            DefaultsManager.set(tokenString, forKey: .APNSToken)
            
            APIManager.sharedInstance.addAPNSToken(tokenString,
                successCallback: { (json) -> Void in
                    
                }) { (json) -> Void in
                    // TODO: handle error
            }
        }
        
        //UIAlertView(title: "didRegisterForRemoteNotificationsWithDeviceToken", message: "\(tokenString)", delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(error: NSError!) {
        Utils.log("Couldn't register: \(error)")
    }
    
    func handleIncomingNotification(userInfo: NSDictionary!) {
        // Additional fields in userInfo:
        /*
        {
            'event': 'order_state_changed',
            'order': { тоже самое что отдает api для активного заказа }
        }
        */
        
        //UIAlertView(title: "handleIncomingNotification", message: "\(userInfo)", delegate: nil, cancelButtonTitle: "OK").show()
        
        Utils.log("handleIncomingNotification \(userInfo)")
        
        if let event = userInfo["event"] as? String {
            if event == "order_state_changed" {
                if let orderID = OrderManager.sharedInstance.currentOrder.pk
                {
                    if let push_id = userInfo["order_id"] as? Int
                    {
                        if push_id == orderID
                        {
                            NotificationManager.post(.OrderStatusChanged, object: userInfo["order_state"])
                        }
                    }
                }
                /*
                if let orderDict = userInfo["order"] as? NSDictionary {
                    if let order = Mapper<OrderModel>().map(orderDict) {
                        NotificationManager.post(.OrderStatusChanged, object: order)
                        
                        return
                    }
                }
                */
                
            }
        }
    }
}