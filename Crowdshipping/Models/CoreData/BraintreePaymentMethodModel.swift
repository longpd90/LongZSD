//
//  BraintreePaymentMethodModel.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 09/04/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation
import CoreData

@objc(BraintreePaymentMethodModel)

class BraintreePaymentMethodModel: NSManagedObject {

    @NSManaged var bin: String?
    @NSManaged var cardType: String?
    @NSManaged var cardholderName: String?
    @NSManaged var isDefault: NSNumber?
    @NSManaged var expirationMonth: String?
    @NSManaged var expirationYear: String?
    @NSManaged var expired: NSNumber?
    @NSManaged var imageURL: String?
    @NSManaged var last4: String?
    @NSManaged var maskedNumber: String?
    @NSManaged var token: String?

    // MARK: mappable
    
    required convenience init?(_ map: [String: AnyObject?]) {
        self.init()
        mapping(map)
    }
    
    func mapping(map: [String: AnyObject?]) {
        self.bin                     = map["bin"] as? String
        self.cardType                = map["card_type"] as? String
        self.cardholderName          = map["cardholder_name"] as? String
        self.isDefault               = map["default"] as? NSNumber
        
        self.expirationMonth         = map["expiration_month"] as? String
        self.expirationYear          = map["expiration_year"] as? String
        self.expired                 = map["expired"] as? NSNumber
        self.imageURL                = map["image_url"] as? String
        self.last4                   = map["last_4"] as? String
        self.maskedNumber            = map["masked_number"] as? String
        self.token                   = map["token"] as? String
    }
    
    func checkIfExpired() -> Bool {
        if expirationMonth == nil ||
            expirationYear == nil
        {
            return false
        }
        
        let components = NSCalendar.currentCalendar().components([.Year, .Month], fromDate:NSDate());

        let year = components.year
        let month = components.month
        
        //Utils.log("\(year) \(month)")
        
        if Int(expirationYear!) > year {
            return false
        } else if Int(expirationYear!) == year {
            if Int(expirationMonth!) >= month {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
}
