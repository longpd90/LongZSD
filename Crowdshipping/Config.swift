//
//  Config.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 18/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation

public struct Config {
    public static let isDevBuild: Bool = {
        let dic = NSProcessInfo.processInfo().environment
        let forceDevBuild = dic["FORCE_DEV_BUILD"] 
        
        if forceDevBuild != nil {
            if (forceDevBuild!.isEqual("1")) {
                return true
            }
        }
        
        return NSBundle.mainBundle().bundleIdentifier!.rangeOfString("dev") != nil
    }()
    
    static let minPasswordLength = 6
    
    static let minCardNumberLength = 12
    static let maxCardNumberLength = 19
    
    static let phoneLength = 8
    static let phoneCodeLength = 4
    static let phonePrefix = isDevBuild ? "+7" : "+65"
    static let officePhone = "+6598210310"
    static let phoneCodeResendInterval = 45
    
    static let defaultGoogleMapsZoom = Float(10)
    
    static let autoSuggestLatitude = 1.368722
    static let autoSuggestLongitude = 103.807815
    
    static let historyPageSize = 20
    static let maxLastAddressCount = 3
    
    static let currentOrderRefreshInterval = NSTimeInterval(5)
    
    // In meters
    static let autoSuggestRadius = "35000"
    
    // In seconds
    static let authTokenLifetime = 30 * 60
    
    // Animations
    static let animationDurationDefault = 0.5
    static let animationDurationCourier = 30.0
    
    // Requests
//    static var domainWithScheme = isDevBuild ? "https://app-dev.zap.delivery" : "https://app.zap.delivery"
    static var domainWithScheme = "https://app.zap.delivery:443"
    
    public static let APIVersionPrefix = "/api/v1"

    static let currency = "SGD "
    
    // Files
    static let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    static let currentOrderFilePath = (documentsPath as NSString).stringByAppendingPathComponent("current_order.data")
    static let userProfileFilePath = (documentsPath as NSString).stringByAppendingPathComponent("user_profile.data")
    
    // Keys
    struct Keys {
        static let googleAPIs = "AIzaSyAYbqGZ0p0vwFt3kY6Lm12JK4GgM_qjCRA"
        static let crashlytics = "cf4eb17c88bfed79c7ded79cd8c82ed1a944f3a0"
        static let intercomAPIKey = "ios_sdk-cca5accfde785e6ad7fe614f2e37aeffb89fae83"
        static let intercomAppID = "k0k7tg8t"
        static let googleAnalyticsKey = isDevBuild ? "UA-63317353-1" : "UA-63317353-2"
    }
    
    // Visuals
    struct Visuals {
        static let color_blue = Utils.Color(74, 144, 226)
        static let color_blueButton = Utils.Color(0, 131, 254)
        static let color_green = Utils.Color(37, 220, 106)
        static let color_red = Utils.Color(255, 72, 19)
        
        static let color_gray_border = Utils.Color(237, 237, 237)
        
        static let color_graySizeSelected = Utils.Color(91, 91, 91)
        static let color_graySizeUnselected = Utils.Color(144, 145, 142)
        static let color_grayUnderline = Utils.Color(176, 176, 176)
        static let color_grayText = Utils.Color(95, 95, 95)
        
        static let color_grayButton = Utils.Color(220, 220, 220)
        static let color_registerButton = Utils.Color(12, 146, 254)
        
        static let color_textDefault = UIColor.blackColor()
        
        static let cornerRadius = CGFloat(12)
    }
}