//
//  Utils.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 23/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation

public class Utils {
    class func log(logMessage: String, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        // TODO: check only once
        let dic = NSProcessInfo.processInfo().environment
        let debugOutput = dic["DEBUG_OUTPUT"] as String?
        
        if debugOutput != nil {
            if (debugOutput!.isEqual("1")) {
                print("\(functionName): \(logMessage)")
            }
        }
    }
    
    class func log(obj: AnyObject?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
        // TODO: check only once
        let dic = NSProcessInfo.processInfo().environment
        let debugOutput = dic["DEBUG_OUTPUT"] as String?
        
        if debugOutput != nil {
            if (debugOutput!.isEqual("1")) {
                print("\(functionName): \(obj?.description)")
            }
        }
    }
    
    /*
    class func validateValue<T>(val: T, validator: (val: T) -> Bool, errorMessage: String) -> Bool {
        let validationResult = validator(val: val)
        
        if !validationResult {
            let av = UIAlertView(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
            av.show()
        }
        
        return validationResult
    }
    */
    
    class func fieldsErrorDescriptionForJSON(json: AnyObject?) -> String? {
        func makeFieldNameHumanReadable(fieldName: String) -> String {
            return fieldName.stringByReplacingOccurrencesOfString("_", withString: " ", options: .LiteralSearch, range: nil).capitalizedString
        }
        
        if json != nil {
            if let fieldErrors = json?["fields"] as? Dictionary<String, Array<String> > {
                
                var errorDescription = ""
                for (name, errors) in fieldErrors {
                    errorDescription += "\(makeFieldNameHumanReadable(name)): "
                    
                    for error in errors {
                        errorDescription += error
                        errorDescription += "\n"
                    }
                }
                return errorDescription
            }
        }
        
        return nil
    }
    
    class func showErrorForJSON(json: AnyObject?) {
        var errorDescription = "An error has occured. Please check your internet connection or try again later."
        
        if json != nil {
            if let code = json?["code"] as? String {
                if code == "account_blocked" {
                    if let reason = json?["block_reason_code"] as? String {
                        if reason == "admin_block" {
                            // Account is blocked - show appropriate screen
                            let blockReason = json?["detail"] as? String
                            
                            AuthManager.sharedInstance.logout()
                            AuthManager.sharedInstance.showUserBlockedWindow(blockReason)
                            
                            return
                        }
                    }
                }
            }
            
            
            if let message = json!["detail"] as? String {
                errorDescription = message
            } else {
                errorDescription = json!.description
            }
            
            if let fieldErrors = Utils.fieldsErrorDescriptionForJSON(json) {
                errorDescription += ("\n" + fieldErrors);
            }
            
        }

        if errorDescription != "An error has occured. Please check your internet connection or try again later."
        {
            let av = UIAlertView(title: "Error", message: errorDescription, delegate: nil, cancelButtonTitle: "OK")
            av.show()
        }
    }
    
    class func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        if NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluateWithObject(email) {
            return true
        }
        return false
    }
    
    public class func ISO8601ToDate(dateString: String) -> NSDate? {
        let formatter = NSDateFormatter();
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        let posix = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.locale = posix;
        
        let date = formatter.dateFromString(dateString)
        
        Utils.log(date)
        
        return date
    }
    
    public class func Color(r: Int, _ g: Int, _ b: Int) -> UIColor {
        let red = CGFloat(r)/255.0
        let green = CGFloat(g)/255.0
        let blue = CGFloat(b)/255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    public class func callPhoneNumber(phoneString: String) {
        if let phoneCallURL = NSURL(string: "tel://\(phoneString)") {
            let application = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    private struct UtilPrivateStruct
    {
        static var staticNextSMSAvaible: Bool = true
        static var staticLastTimerValue: Int = Config.phoneCodeResendInterval
    }
    
    public class var lastTimerValue: Int
    {
        get { return UtilPrivateStruct.staticLastTimerValue }
        set { UtilPrivateStruct.staticLastTimerValue = newValue }
    }
    
    public class func startSMSTimer()
    {
        UtilPrivateStruct.staticNextSMSAvaible = false
        delay(Double(Config.phoneCodeResendInterval))
        {
            UtilPrivateStruct.staticNextSMSAvaible = true
            UtilPrivateStruct.staticLastTimerValue = Config.phoneCodeResendInterval
        }
    }
    
    public class func isNextSMSAvaible() -> Bool
    {
        return UtilPrivateStruct.staticNextSMSAvaible
    }
    
    class func delay(delay:Double, closure:()->())
    {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}