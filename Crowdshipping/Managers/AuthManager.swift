//
//  AuthManager.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 16/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation
import CoreData

public class AuthManager {
    lazy var context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    private var loggedIn = false;
    var authToken: String? = nil;
    private var braintreeKey: String? = nil
    
    private var isPhoneConfirmed: Bool = false
    private var phone: String?
    
    private lazy var paymentMethods: [BraintreePaymentMethodModel] = { return self.getAllPaymentMethods() }()
    
    internal var userProfile: UserProfileModel?
    
    init() {
        authToken = DefaultsManager.get(.AuthToken) as? String
        braintreeKey = DefaultsManager.get(.BraintreeKey) as? String
        
        if (authToken != nil) {
            loggedIn = true
            
            isPhoneConfirmed    = DefaultsManager.getBool(forKey: .IsPhoneConfirmed)
            phone               = DefaultsManager.get(.Phone) as? String
        }
        
        userProfile = NSKeyedUnarchiver.unarchiveObjectWithFile(Config.userProfileFilePath) as? UserProfileModel
        
        if let userID = userProfile?.id {
            Intercom.registerUserWithUserId(String(userID))
        } else {
            Intercom.registerUnidentifiedUser()
        }
    }
    
    public class var sharedInstance : AuthManager {
        struct Static {
            static let instance : AuthManager = AuthManager()
        }
        
        return Static.instance
    }
    
    public func login(token: String) {
        let timestamp = Int(NSDate().timeIntervalSince1970)
        DefaultsManager.set(token, forKey: .AuthToken)
        DefaultsManager.set(timestamp, forKey: .AuthTokenTimestamp)
        
        authToken = token
        loggedIn = true
    }
    
    func logout() {        
        DefaultsManager.remove(.AuthToken)
        DefaultsManager.remove(.IsPhoneConfirmed)
        DefaultsManager.remove(.Phone)
        
        loggedIn = false
        authToken = nil
        
        isPhoneConfirmed = false
        phone = nil
        
        // Clear core data objects
        context.removeAllEntitiesOfType("LastUsedAddress")
        context.removeAllEntitiesOfType("BraintreePaymentMethodModel")
    }
        
    func isLoggedIn() -> Bool {
        return loggedIn
    }
    
    func finalizeLogin() {
        APIManager.sharedInstance.getBraintreeToken({(arg) in }, failedCallback: {(arg) in })
        APNSManager.sharedInstance.register()
        LocationManager.sharedInstance.startUpdating()
        
        if AddressesManager.sharedInstance.getLastAddressesForType(.Pickup).count == 0 ||
            AddressesManager.sharedInstance.getLastAddressesForType(.Destination).count == 0 {
            APIManager.sharedInstance.getOrderList(1,
                successCallback: { (arg) -> Void in
                    if let newOrders = arg!["results"] as? Array< Dictionary<String, AnyObject> > {
                        for i in 0 ..< min(Config.maxLastAddressCount, newOrders.count) {
                            if let newOrder = Mapper<OrderModel>().map(newOrders[i]) {
                                AddressesManager.sharedInstance.addAddress(newOrder.pickupAddress!, date: NSDate(), type: .Pickup, coordinate: newOrder.pickupPosition!)
                                AddressesManager.sharedInstance.addAddress(newOrder.destinationAddress!, date: NSDate(), type: .Destination, coordinate: newOrder.destinationPosition!)
                            }
                        }
                    }
            }, failedCallback: { (arg) -> Void in
                // Fail silently
            })
        }
    }

    // Profile
    func setProfile(profile: [String: AnyObject]) {
        userProfile = Mapper<UserProfileModel>().map(profile)
        
        if userProfile != nil {
            NSKeyedArchiver.archiveRootObject(userProfile!, toFile: Config.userProfileFilePath)
        }
        
        if let userID = userProfile?.id {
            Intercom.registerUserWithUserId(String(userID))
        }
        
        paymentMethods = []
        if let paymentMethodsArray = profile["payment_methods"] as? Array< Dictionary<String, AnyObject> > {
            for methodDict in paymentMethodsArray {
                addPaymentMethod(methodDict)
            }
        }
        
        if let isPhoneConfirmed = profile["is_phone_confirmed"] as? Bool {
            self.isPhoneConfirmed = isPhoneConfirmed
            DefaultsManager.setBool(isPhoneConfirmed, forKey: .IsPhoneConfirmed)
        }
        
        if let phone = profile["phone"] as? String {
            self.phone = phone
            DefaultsManager.set(phone, forKey: .Phone)
        }
    }
    
    // MARK: Payment method management
    func addPaymentMethod(method: Dictionary<String, AnyObject>) {
        var newMethod = NSEntityDescription.insertNewObjectForEntityForName("BraintreePaymentMethodModel",
            inManagedObjectContext: context) as! BraintreePaymentMethodModel
        
        newMethod.mapping(method)
        
        if let isDefault = newMethod.isDefault {
            if isDefault.boolValue {
                let request = NSFetchRequest(entityName: "BraintreePaymentMethodModel")
                
                if let paymentMethodsFromCoreData = self.context.extendedExecuteFetchRequest(request) {
                    for method in paymentMethodsFromCoreData {
                        if method != newMethod {
                            (method as! BraintreePaymentMethodModel).isDefault = NSNumber(bool: false)
                        }
                    }
                }
            }
        }
        
        paymentMethods.append(newMethod)
        
        context.extendedSave()
    }
    
    func removePaymentMethod(method: BraintreePaymentMethodModel) {
        context.deleteObject(method)
        
        context.extendedSave()
    }
    
    func setPaymentMethodDefault(newDefaultMethod: BraintreePaymentMethodModel) {
        let request = NSFetchRequest(entityName: "BraintreePaymentMethodModel")
        
        if let paymentMethodsFromCoreData = self.context.extendedExecuteFetchRequest(request) {
            for method in paymentMethodsFromCoreData {
                if method != newDefaultMethod {
                    (method as! BraintreePaymentMethodModel).isDefault = NSNumber(bool: false)
                }
            }
        }
        
        newDefaultMethod.isDefault = NSNumber(bool: true)
        context.extendedSave()
    }
    
    // MARK: Getters & setters
    func shouldBindPhone() -> Bool {
        return (phone == nil) || !isPhoneConfirmed
    }
    
    func getPhone() -> String? {
        return phone
    }
    
    func setIsPhoneConfirmed(confirmed: Bool) {
        isPhoneConfirmed = confirmed
        DefaultsManager.setBool(isPhoneConfirmed, forKey: .IsPhoneConfirmed)
    }
    
    func setBraintreeKey(key: String) {
        DefaultsManager.set(key, forKey: .BraintreeKey)
        braintreeKey = key
    }
    
    func getBraintreeKey() -> String? {
        return braintreeKey
    }
    
    func getHasPaymentMethod() -> Bool {
        return paymentMethods.count != 0
    }
    
    // Profile
    func getAllPaymentMethods() -> [BraintreePaymentMethodModel] {
        let request = NSFetchRequest(entityName: "BraintreePaymentMethodModel")
        
        if let paymentMethodsFromCoreData = self.context.extendedExecuteFetchRequest(request) {
            return paymentMethodsFromCoreData as! [BraintreePaymentMethodModel]
        }
        
        return []
    }
    
    func getDefaultPaymentMethod() -> BraintreePaymentMethodModel? {
        let methods = getAllPaymentMethods()
        
        if methods.count == 0 {
            return nil
        }
        
        for m in methods {
            if let def = m.isDefault as? Bool {
                if def {
                    return m
                }
            }
        }
        
        return methods[0]
    }
    
    // MARK: Other public methods
    
    func showUserBlockedWindow(reason: String?) {
        if let window = UIApplication.sharedApplication().windows[0] as? UIWindow {        
            let ubvc = UserBlockedVC()
            ubvc.reason = reason
            
            let nc = UINavigationController(rootViewController: ubvc)
            ubvc.nc = nc
            window.addSubview(nc.view)
            
            nc.view.frame = window.bounds
            nc.view.layoutSubviews()
        }
    }
}