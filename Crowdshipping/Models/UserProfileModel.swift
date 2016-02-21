//
//  UserProfileModel.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 17/04/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

public class UserProfileModel: NSObject, NSCoding, Mappable {
    var id: Int?
    var phone: String?
    var isEmailConfirmed: Bool?
    var isPhoneConfirmed: Bool?
    var email: String?
    var firstName: String?
    var lastName: String?
    var photoURL: String?

    required convenience public init?(_ map: Map) {
        self.init()
        mapping(map)
    }
    
    public func mapping(map: Map) {
        id                      <- map["id"]
        phone                   <- map["phone"]
        isEmailConfirmed        <- map["is_email_confirmed"]
        isPhoneConfirmed        <- map["is_phone_confirmed"]
        email                   <- map["email"]
        firstName               <- map["first_name"]
        lastName                <- map["last_name"]
        photoURL                <- map["photo"]
    }
    
    // MARK: NSCoding
    
    required convenience public init(coder decoder: NSCoder) {
        self.init()
        
        id                  = Int(decoder.decodeIntForKey("id"))
        phone               = decoder.decodeObjectForKey("phone") as? String
        isEmailConfirmed    = decoder.decodeBoolForKey("isEmailConfirmed")
        isPhoneConfirmed    = decoder.decodeBoolForKey("isPhoneConfirmed")
        email               = decoder.decodeObjectForKey("email") as? String
        firstName           = decoder.decodeObjectForKey("firstName") as? String
        lastName            = decoder.decodeObjectForKey("lastName") as? String
        photoURL            = decoder.decodeObjectForKey("photoURL") as? String
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        id != nil ? coder.encodeInt(Int32(id!), forKey: "id") :
        coder.encodeObject(phone, forKey: "phone")

        if isEmailConfirmed != nil { coder.encodeBool(isEmailConfirmed!, forKey: "isEmailConfirmed") }
        if isPhoneConfirmed != nil { coder.encodeBool(isPhoneConfirmed!, forKey: "isPhoneConfirmed") }
        
        coder.encodeObject(email, forKey: "email")
        coder.encodeObject(firstName, forKey: "firstName")
        coder.encodeObject(lastName, forKey: "lastName")
        coder.encodeObject(photoURL, forKey: "photoURL")
    }
}
