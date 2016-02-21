//
//  NotificationManager.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 07/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class NotificationManager {
    enum NotificationName : String {
        case
            UserDidLogout = "UserDidLogout",
            OrderStatusChanged = "OrderStatusChanged" // Triggered by remote notif.
    }
    
    class func post(notificationName: NotificationName) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName.rawValue, object: nil)
    }
    
    class func post(notificationName: NotificationName, object: AnyObject?) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName.rawValue, object: object)
    }
    
    class func post(notificationName: NotificationName, object: AnyObject?, userInfo: [NSObject : AnyObject]?) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName.rawValue, object: object, userInfo: userInfo)
    }
    
    class func addObserver(observer: AnyObject, selector: Selector, name: NotificationName?) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: name?.rawValue, object: nil)
    }
    
    class func addObserver(observer: AnyObject, selector: Selector, name: NotificationName?, object: AnyObject?) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: name?.rawValue, object: object)
    }
    
    class func removeObserver(observer: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
}
