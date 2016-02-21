//
//  AuthManager.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 16/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class DefaultsManager {
    enum Key : String {
        case
            AuthToken = "AuthToken",
            AuthTokenTimestamp = "AuthTokenTimestamp",
            BraintreeKey = "BraintreeKey",
            APNSToken = "APNSToken",
            IsPhoneConfirmed = "IsPhoneConfirmed",
            Phone = "Phone",
            LastSuccessfullLoginPhone = "LastSuccessfullLoginPhone"
    }
    
    class var sharedInstance : DefaultsManager {
        struct Static {
            static let instance : DefaultsManager = DefaultsManager()
        }
        return Static.instance
    }
    
    
    class func set(obj: AnyObject, forKey key: Key) {
        NSUserDefaults.standardUserDefaults().setObject(obj, forKey: key.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func get(key: Key) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(key.rawValue)
    }
    
    class func setBool(obj: Bool, forKey key: Key) {
        NSUserDefaults.standardUserDefaults().setBool(obj, forKey: key.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getBool(forKey key: Key) -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(key.rawValue)
    }
    
    class func remove(key: Key) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(key.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}