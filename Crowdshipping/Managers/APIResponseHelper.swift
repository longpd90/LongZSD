//
//  APIResponseHelper.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 10/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation

class APIResponseHelper {
    var successCallback: (AnyObject?) -> Void
    var failedCallback: (AnyObject?) -> Void
    var tokenRefreshCallback: () -> Void
    var completionHandler: ((NSURLRequest?, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void)?
    
    func nsdataToJSON(data: NSData) -> AnyObject? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    
    init(successCallback: (AnyObject?) -> Void,
        failedCallback: (AnyObject?) -> Void,
        tokenRefreshCallback: () -> Void = {},
        canSendTokenRefreshResponse: Bool = true)
    {
        self.successCallback = successCallback
        self.failedCallback = failedCallback
        self.tokenRefreshCallback = tokenRefreshCallback
        
        self.completionHandler = { (request, response, json, error) -> Void in
            let responseCode = response?.statusCode

            Utils.log(json)
            Utils.log("responseCode: \(responseCode)")
            Utils.log(error)
            let realJSON = self.nsdataToJSON(json as! NSData)
            if canSendTokenRefreshResponse && responseCode == 401 {
                AuthManager.sharedInstance.logout()
                self.failedCallback(json)
                return
                /*
                APIManager.sharedInstance.refreshAuthToken(AuthManager.sharedInstance.authToken!,
                    successCallback: tokenRefreshCallback,
                    failedCallback: { () -> Void in failedCallback(nil) } )
                return
                */
            }
            
            var success = false
            //if (json != nil) {
                if ((200 <= responseCode) && (responseCode < 300)) {
                    success = true
                }
            //}
            
            if success {
                self.successCallback(realJSON)
            } else {
                self.failedCallback(realJSON)
            }
        }
    }
}

