//
//  APIManager.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 18/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation
import Alamofire

public class APIManager {
    public class var sharedInstance : APIManager {
        struct Static {
            static let instance : APIManager = APIManager()
        }
        return Static.instance
    }

    // MARK: - Crowdshipping API
    // MARK: Methods without auth
    public func register(firstName: String, lastName: String, phone: String, password: String,
        successCallback: () -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.Register(firstName: firstName, lastName: lastName, phone: phone, password: password)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
            let jsonResult = arg as? Dictionary<String, AnyObject>
            
            if let token = jsonResult?["token"] as? String {
                AuthManager.sharedInstance.login( token )
                AuthManager.sharedInstance.finalizeLogin()

                if let profile = jsonResult?["profile"] as? [String: AnyObject] {
                    AuthManager.sharedInstance.setProfile(profile)
                }
                
                successCallback()
            } else {
                failedCallback(jsonResult)
            }

        }, failedCallback: { (arg) -> Void in
            failedCallback(arg as? Dictionary<String, AnyObject>)
        })

//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func login(phone: String, password: String,
        successCallback: () -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.Login(phone: phone, password: password)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
            let jsonResult = arg as? Dictionary<String, AnyObject>
            
            if let token = jsonResult?["token"] as? String {
                AuthManager.sharedInstance.login( token )
                AuthManager.sharedInstance.finalizeLogin()
                
                if let profile = jsonResult?["profile"] as? [String: AnyObject] {
                    AuthManager.sharedInstance.setProfile(profile)
                }
                
                successCallback()
            } else {
                failedCallback(arg as? Dictionary<String, AnyObject>)
            }
        },
        failedCallback: { (arg) -> Void in
            failedCallback(arg as? Dictionary<String, AnyObject>)
        },
            tokenRefreshCallback: { () -> Void in },
            canSendTokenRefreshResponse: false)
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func changePassword(oldPassword: String, newPassword: String,
        successCallback: () -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.ChangePassword(oldPassword: oldPassword, newPassword: newPassword)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
            successCallback()
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
        })
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func changePersonalInfo(firstName: String, lastName: String,
        successCallback: () -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.ChangePersonalInfo(firstName: firstName, lastName: lastName)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
            successCallback()
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
        })
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    // Gets parameters from OrderManager singleton
    public func getQuote(successCallback: (Dictionary<String, AnyObject>?) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        // Returns:
        /*
            ["origin_address": 141A Lorong 2 Toa Payoh, Singapore 310141, "duration": 661, "distance": 5761, "prices": (
                    {
                    "delivery_interval" = "<null>";
                    "pickup_interval" = "<null>";
                    price = "23.04";
                    size = LARGE;
                },
                    {
                    "delivery_interval" = "<null>";
                    "pickup_interval" = "<null>";
                    price = "17.28";
                    size = MEDIUM;
                },
                    {
                    "delivery_interval" = "<null>";
                    "pickup_interval" = "<null>";
                    price = "11.52";
                    size = SMALL;
                }
            ), "destination_address": 141 Serangoon Road, Singapore 218042]
        */
        
        let r = Router.GetQuote()
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                successCallback(arg as? Dictionary<String, AnyObject>)
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
            },
            tokenRefreshCallback: { () -> Void in },
            canSendTokenRefreshResponse: false)
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func restorePassword(phone: String,
        successCallback: () -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.RestorePassword(phone: phone)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                successCallback()
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
            })
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func restorePasswordCheckCode(phone: String,
        code: String,
        successCallback: () -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.RestorePasswordConfirm(phone: phone, code: code, password: nil)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                successCallback()
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
        })
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func restorePasswordConfirm(phone: String,
        code: String,
        password: String?,
        successCallback: () -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.RestorePasswordConfirm(phone: phone, code: code, password: password)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
            // TODO: refactor all auth callbacks
                let jsonResult = arg as? Dictionary<String, AnyObject>
                
                if let token = jsonResult?["token"] as? String {
                    AuthManager.sharedInstance.login( token )
                    AuthManager.sharedInstance.finalizeLogin()
                    
                    if let profile = jsonResult?["profile"] as? [String: AnyObject] {
                        AuthManager.sharedInstance.setProfile(profile)
                    }
                    
                    successCallback()
                } else {
                    failedCallback(arg as? Dictionary<String, AnyObject>)
                }
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
        })
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func getNearbyCouriers(northeast: CLLocationCoordinate2D,
        southwest: CLLocationCoordinate2D,
        successCallback: ([CourierTrackModel]) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.GetNearbyCouriers(northeast: northeast, southwest: southwest)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                var couriers = Array<CourierTrackModel>()
                if let responseArray = arg as? [AnyObject] {
                    for obj in responseArray {
                        if let courier = Mapper<CourierTrackModel>().map(obj) {
                            couriers.append(courier)
                        }
                    }
                }
            
                successCallback(couriers)
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
        })
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    // MARK: Methods with auth
    
    public func bindCard(token: String,
        successCallback: (Dictionary<String, AnyObject>?) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.BindCard(token: token)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                successCallback(arg as? Dictionary<String, AnyObject>)
                if let dict = arg as? Dictionary<String, AnyObject> {
                    AuthManager.sharedInstance.addPaymentMethod(dict)
                }
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
            },
            tokenRefreshCallback: { () -> Void in
                self.bindCard(token, successCallback: successCallback, failedCallback: failedCallback)
            },
            canSendTokenRefreshResponse: true)
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func deleteCard(pk: String,
        successCallback: (Dictionary<String, AnyObject>?) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.DeletePaymentMethod(pk: pk)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                successCallback(arg as? Dictionary<String, AnyObject>)
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
            })
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func makeCardDefault(token: String,
        successCallback: (Dictionary<String, AnyObject>?) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.MakePaymentMethodDefault(token: token)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
            successCallback(arg as? Dictionary<String, AnyObject>)
        },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
        })
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func updateCard(token: String,
        expMonth: String,
        expYear: String,
        verificationValue: String,
        successCallback: (Dictionary<String, AnyObject>?) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.UpdatePaymentMethod(token: token, expMonth: expMonth, expYear: expYear, verificationValue: verificationValue)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
            successCallback(arg as? Dictionary<String, AnyObject>)
        },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
        })
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func makeOrder(successCallback: (Dictionary<String, AnyObject>) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.MakeOrder()
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                if arg != nil {
                    // !!!: save pickup/destination addresses
                    AddressesManager.sharedInstance.addCurrentOrderAddresses()
                    
                    successCallback(arg as! Dictionary<String, AnyObject>)
                } else {
                    failedCallback(nil)
                }
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
            },
            tokenRefreshCallback: { () -> Void in
                self.makeOrder(successCallback, failedCallback: failedCallback)
            },
            canSendTokenRefreshResponse: true)
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func getOrderList(page: Int,
        successCallback: (Dictionary<String, AnyObject>?) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        //Returns:
        /*
        {
            count = 1;
            next = "<null>";
            previous = "<null>";
            results =     (
                        {
                    courier = "<null>";
                    created = "2015-02-24T11:56:55.288121Z";
                    "destination_address" = "Optional(\"141a Lorong 2 Toa Payoh Singapore\")";
                    "destination_phone" = "+6598804324";
                    "destination_position" =             {
                        coordinates =                 (
                            "103.84559",
                            "1.335212"
                        );
                        type = Point;
                    };
                    "estimated_delivery_interval" = "<null>";
                    "estimated_pickup_interval" = "<null>";
                    events =             (
                    );
                    id = 9;
                    modified = "2015-02-24T11:56:55.297306Z";
                    "pickup_address" = "Optional(\"141 Serangoon Road Singapore\")";
                    "pickup_phone" = "+6598804321";
                    "pickup_position" =             {
                        coordinates =                 (
                            "103.852583",
                            "1.307792"
                        );
                        type = Point;
                    };
                    price = "12.25";
                    size = SMALL;
                    state = NEW;
                }
            );
        }
        */
        
        let r = Router.GetOrderList(page: page)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                successCallback(arg as? Dictionary<String, AnyObject>)
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
            },
            tokenRefreshCallback: { () -> Void in
                self.getOrderList(page, successCallback: successCallback, failedCallback: failedCallback)
            },
            canSendTokenRefreshResponse: true)
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func cancelOrder(pk: Int, parameters: Dictionary<String, AnyObject>?,
        successCallback: (Dictionary<String, AnyObject>?) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.CancelOrder(pk: pk, parameters: parameters)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                successCallback(arg as? Dictionary<String, AnyObject>)
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
            },
            tokenRefreshCallback: { () -> Void in
                self.cancelOrder(pk, parameters: parameters, successCallback: successCallback, failedCallback: failedCallback)
            },
            canSendTokenRefreshResponse: true)
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func republishOrder(pk: Int,
        successCallback: (Dictionary<String, AnyObject>?) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.RepublishOrder(pk: pk)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
            successCallback(arg as? Dictionary<String, AnyObject>)
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
            },
            tokenRefreshCallback: { () -> Void in
                self.republishOrder(pk, successCallback: successCallback, failedCallback: failedCallback)
            },
            canSendTokenRefreshResponse: true)
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func addAPNSToken(token: String,
        successCallback: (Dictionary<String, AnyObject>?) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.AddAPNSToken(token: token)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                successCallback(arg as? Dictionary<String, AnyObject>)
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
            },
            tokenRefreshCallback: { () -> Void in
                self.addAPNSToken(token, successCallback: successCallback, failedCallback: failedCallback)
            },
            canSendTokenRefreshResponse: true)
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func refreshAuthToken(token: String,
        successCallback: () -> Void,
        failedCallback: () -> Void)
    {
        Utils.log(token)
        
        let params = ["token": token.urlEncode()]
        
        let urlString = Config.domainWithScheme + Config.APIVersionPrefix + "/common/account/refresh_token/"
        let req = request(.POST, urlString, parameters: params)
        
//        req.responseJSON { (request, response, json, error) -> Void in
//            Utils.log(request)
//            
//            let responseCode = response?.statusCode
//            Utils.log("refreshAuthToken Status: \(responseCode)");
//            
//            var success = false
//            
//            if let jsonResult = json as? Dictionary<String,AnyObject> {
//                Utils.log(json)
//                
//                if (200 <= responseCode) && (responseCode < 300) {
//                    
//                    if let token = jsonResult["token"] as? String {
//                        success = true
//                        AuthManager.sharedInstance.login(token)
//                        successCallback()
//                        return
//                    }
//                }
//            }
//            
//            // "Signature has expired."
//            if responseCode == 400 {
//                AuthManager.sharedInstance.logout()
//            }
//            
//            if !success {
//                failedCallback()
//            }
//        }
        
        req.response { (request, response, json, error) -> Void in
            Utils.log(request)
            
            let responseCode = response?.statusCode
            Utils.log("refreshAuthToken Status: \(responseCode)");
            
            var success = false
            
            if let jsonResult = json as? Dictionary<String,AnyObject> {
                Utils.log(json)
                
                if (200 <= responseCode) && (responseCode < 300) {
                    
                    if let token = jsonResult["token"] as? String {
                        success = true
                        AuthManager.sharedInstance.login(token)
                        successCallback()
                        return
                    }
                }
            }
            
            // "Signature has expired."
            if responseCode == 400 {
                AuthManager.sharedInstance.logout()
            }
            
            if !success {
                failedCallback()
            }
        }
    }
    
    public func logout(successCallback: (Dictionary<String, AnyObject>?) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.Logout()
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                successCallback(arg as? Dictionary<String, AnyObject>)
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
            },
            tokenRefreshCallback: { () -> Void in
            },
            canSendTokenRefreshResponse: false)
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }

    public func getOrderDetails(pk: Int,
        successCallback: (Dictionary<String, AnyObject>?) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.GetOrderDetails(pk: pk)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                successCallback(arg as? Dictionary<String, AnyObject>)
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
            },
            tokenRefreshCallback: { () -> Void in
                self.logout(successCallback, failedCallback: failedCallback)
            },
            canSendTokenRefreshResponse: true)
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func getActiveOrderDetails(successCallback: (Dictionary<String, AnyObject>?) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.GetActiveOrderDetails()
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                successCallback(arg as? Dictionary<String, AnyObject>)
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
            },
            tokenRefreshCallback: { () -> Void in },
            canSendTokenRefreshResponse: true)
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func bindPhone(phone: String?,
        successCallback: (Dictionary<String, AnyObject>?) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.BindPhone(phone: phone)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                successCallback(arg as? Dictionary<String, AnyObject>)
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
            },
            tokenRefreshCallback: { () -> Void in },
            canSendTokenRefreshResponse: true)
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func confirmPhone(code: String,
        successCallback: (Dictionary<String, AnyObject>?) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void)
    {
        let r = Router.ConfirmPhone(code: code)
        let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                AuthManager.sharedInstance.setIsPhoneConfirmed(true)
            
                successCallback(arg as? Dictionary<String, AnyObject>)
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? Dictionary<String, AnyObject>)
            },
            tokenRefreshCallback: { () -> Void in },
            canSendTokenRefreshResponse: true)
        
//        request(r).responseJSON(helper.completionHandler!)
        request(r).response(completionHandler: helper.completionHandler!)
    }
    
    public func getBraintreeToken(successCallback: () -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void) {
        let r = Router.GetBraintreeToken()
        let helper = APIResponseHelper(successCallback: { (json) -> Void in
            if let token = json?["client_token"] as? String {
                AuthManager.sharedInstance.setBraintreeKey(token)
                successCallback()
            } else {
                failedCallback(json as? [String:AnyObject])
            }
            },
            failedCallback: { (arg) -> Void in
                failedCallback(arg as? [String:AnyObject])
            })
        
//        request(r).responseJSON(helper.completionHandler!)
            request(r).response(completionHandler: helper.completionHandler!)
    }
    
    /*
    MARK: Google places API
    */
    
    public func getPlaceAutosuggestions(var searchQuery: String!,
        successCallback: (Array< Dictionary<String, AnyObject> >) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void,
        useProxy: Bool = true)
    {
        if useProxy {
            var lat = Config.autoSuggestLatitude
            var lng = Config.autoSuggestLongitude
            
            if let loc = LocationManager.sharedInstance.lastLocation {
                lat = loc.coordinate.latitude
                lng = loc.coordinate.longitude
            }
            
            let r = Router.GetPlaceAutosuggestions(searchQuery: searchQuery, lat: lat, lng: lng)
            
            let helper = APIResponseHelper(successCallback: { (arg) -> Void in
                    if let array = arg as? Array< Dictionary<String,AnyObject> > {
                        successCallback(array)
                    } else {
                        successCallback([])
                    }
                },
                failedCallback: { (arg) -> Void in
                    failedCallback(arg as? Dictionary<String, AnyObject>)
                })
            
//            request(r).responseJSON(helper.completionHandler!)
            request(r).response(completionHandler: helper.completionHandler!)
        } else {
            let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
            var params = [
                "input": searchQuery,
                "location": "\(Config.autoSuggestLatitude),\(Config.autoSuggestLongitude)"
            ]
            params["key"] = Config.Keys.googleAPIs
            params["radius"] = Config.autoSuggestRadius
            
            let registerRequest = request(.GET, urlString, parameters: params, encoding: .URL)
            
//            registerRequest.responseJSON { (request, response, json, error) -> Void in
//                //Utils.log(request)
//                
//                let responseCode = response?.statusCode
//                //Utils.log("Status: \(responseCode)");
//                
//                var success = false
//                
//                if let jsonResult = json as? Dictionary<String,AnyObject> {
//                    Utils.log(json)
//                    
//                    if ((200 <= responseCode) && (responseCode < 300)) {
//                        if let predictions = jsonResult["predictions"] as? Array< Dictionary<String, AnyObject> > {
//                            success = true
//                            successCallback(predictions)
//                        }
//                    }
//                }
//                
//                if !success {
//                    failedCallback(json as? Dictionary<String,AnyObject>)
//                }
//            }

            registerRequest.response { (request, response, json, error) -> Void in
                //Utils.log(request)
                
                let responseCode = response?.statusCode
                //Utils.log("Status: \(responseCode)");
                
                var success = false
                
                if let jsonResult = json as? Dictionary<String,AnyObject> {
                    Utils.log(json)
                    
                    if ((200 <= responseCode) && (responseCode < 300)) {
                        if let predictions = jsonResult["predictions"] as? Array< Dictionary<String, AnyObject> > {
                            success = true
                            successCallback(predictions)
                        }
                    }
                }
                
                if !success {
                    failedCallback(json as? Dictionary<String,AnyObject>)
                }
            }
        }
    }
    
    public func getLocationAddress(location: CLLocationCoordinate2D!,
        successCallback: (String?) -> Void,
        failedCallback: () -> Void)
    {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(location,
            completionHandler: { (response, error) -> Void in
                if response != nil {
                    if let result = response.firstResult()  {
                        if let thoroughfare = result.thoroughfare {
                            //Utils.log(thoroughfare)
                            successCallback(thoroughfare)
                            return
                        } else if let address = result.lines[0] as? String {
                            successCallback(address)
                            return
                        }
                    }
                }
                failedCallback()
        })
    }
    
    public func getPlaceInfo(var placeID: String,
        successCallback: (Dictionary<String, AnyObject>) -> Void,
        failedCallback: (Dictionary<String, AnyObject>?) -> Void,
        useProxy: Bool = true)
    {
        placeID = placeID.urlEncode()
        let urlString = Config.domainWithScheme + Config.APIVersionPrefix + "/sender/autocomplete/google_place/\(placeID)/"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            var responseCode = 0
            if let reponseHTTP = response as? NSHTTPURLResponse {
                responseCode = reponseHTTP.statusCode
            }
            
            var json: Dictionary<String,AnyObject>?
            do {
                json = try  NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? Dictionary<String,AnyObject>
            } catch {}
            //Utils.log(json)
            
            var success = false
            if ((200 <= responseCode) && (responseCode < 300)) {
                if json != nil {
                    success = true
                    successCallback(json!)
                }
            }
            
            if !success {
                failedCallback(json)
            }
        }
    }
    
    public func bindCardBraintree(
        cardNumber: String,
        _ verificationValue: String,
        _ month: String,
        _ year: String,
        successCallback: (String) -> Void,
        failedCallback: (AnyObject?) -> Void)
    {
        let token = AuthManager.sharedInstance.getBraintreeKey()
        
        if token == nil {
            self.getBraintreeToken({ () -> Void in
                self.bindCardBraintree(cardNumber, verificationValue, month, year, successCallback: successCallback, failedCallback: failedCallback)
            }, failedCallback: { (arg) -> Void in
                failedCallback(arg)
            })
            
            return
        }
        
        let braintree = Braintree(clientToken: token!)
        let request = BTClientCardRequest()
        
        request.number = cardNumber
        request.expirationMonth = month
        request.expirationYear = year
        request.cvv = verificationValue
                
        braintree!.tokenizeCard(request, completion: { (nonce, error) -> Void in
            Utils.log("nonce: \(nonce)")
            Utils.log("error: \(error)")
            
            if error != nil {
                failedCallback(["details" : "An error occured. Please try again later."])
            } else {
                successCallback(nonce!)
            }
        })
    } 
}