//
//  AuthManager.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 16/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation

public class OrderManager {

    public var currentOrder : OrderModel
    
    let orderIdentifer: String = "currentOrder"
    
    deinit {
        NotificationManager.removeObserver(self)
    }
    
    // MARK: Notifications
    
    // "@objc" fixes NSForwarding: warning ... does not implement methodSignatureForSelector:
    @objc func userDidLogout() {
        self.resetOrder()
        NSUserDefaults.standardUserDefaults().removeObjectForKey(orderIdentifer)
    }
    
    init() {
        
        currentOrder = OrderModel()
        
        if let orderData = NSUserDefaults.standardUserDefaults().objectForKey(orderIdentifer) as? NSData
        {
            if let orderValue = NSKeyedUnarchiver.unarchiveObjectWithData(orderData) as? OrderModel
            {
                currentOrder = orderValue
            }
        }
        NotificationManager.addObserver(self, selector: Selector("userDidLogout"), name: .UserDidLogout)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("appDidClosed"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    public class var sharedInstance : OrderManager {
        struct Static {
            static let instance : OrderManager = OrderManager()
        }
        return Static.instance
    }
    
    func deleteSavedOrder() {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(Config.currentOrderFilePath)
        } catch {}
    }
 
    func resetOrder() {
        currentOrder = OrderModel()
        NSUserDefaults.standardUserDefaults().removeObjectForKey(orderIdentifer)
    }
    
    @objc internal func appDidClosed()
    {
        if currentOrder.pk != nil
        {
            let data = NSKeyedArchiver.archivedDataWithRootObject(currentOrder)
            NSUserDefaults.standardUserDefaults().setObject(data, forKey: orderIdentifer)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}