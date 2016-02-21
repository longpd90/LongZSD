//
//  Router.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 10/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    case MakeOrder()
    case BindCard(token: String)
    case GetQuote()
    case GetOrderList(page: Int)
    case CancelOrder(pk: Int, parameters: Dictionary<String, AnyObject>?)
    case RepublishOrder(pk: Int)
    case AddAPNSToken(token: String)
    case Login(phone: String, password: String)
    case ChangePassword(oldPassword: String, newPassword: String)
    case ChangePersonalInfo(firstName: String, lastName: String)
    case Logout()
    case GetOrderDetails(pk: Int)
    case GetActiveOrderDetails()
    case BindPhone(phone: String?)
    case ConfirmPhone(code: String)
    case Register(firstName: String, lastName: String, phone: String, password: String)
    case GetBraintreeToken()
    case GetPlaceAutosuggestions(searchQuery: String, lat: Double, lng: Double)
    case RestorePassword(phone: String)
    case RestorePasswordConfirm(phone: String, code: String, password: String?)
    case GetNearbyCouriers(northeast: CLLocationCoordinate2D, southwest: CLLocationCoordinate2D)
    case DeletePaymentMethod(pk: String)
    case UpdatePaymentMethod(token: String, expMonth: String, expYear: String, verificationValue: String)
    case MakePaymentMethodDefault(token: String)
    
    var URLRequest: NSMutableURLRequest {
        let result: (path: String, parameters: [String: AnyObject]?, addAuthToken: Bool, method: String) = {
            switch self {
            case .MakeOrder():
                let currentOrder = OrderManager.sharedInstance.currentOrder
                
                let point1 = currentOrder.getPickupPositionGeoJSON()
                let point2 = currentOrder.getDestinationPositionGeoJSON()
                
                let address1 = currentOrder.pickupAddress!
                let address2 = currentOrder.destinationAddress!
                
                let phone1 = currentOrder.pickupPhone!
                let phone2 = currentOrder.destinationPhone!
                
                let size = currentOrder.orderSize!.rawValue
                
                let paymentMethod = currentOrder.paymentMethod!
                
                var params = [
                    "size":       size,
                    "pickup_position":      point1,
                    "destination_position": point2,
                    "pickup_phone":         phone1,
                    "destination_phone":    phone2,
                    "pickup_address":       address1,
                    "destination_address":  address2,
                    "payment_method": paymentMethod
                ]
                
                if currentOrder.notes != nil {
                    let notes = currentOrder.notes!
                    params["note"] = notes
                }
                
                if let pickupAddressDetail = currentOrder.pickupAddressDetail {
                    params["pickup_address_detail"] = pickupAddressDetail
                }
                
                if let destinationAddressDetail = currentOrder.destinationAddressDetail {
                    params["destination_address_detail"] = destinationAddressDetail
                }
                
                return ("/sender/order/", params, true, "POST")
                
            case .BindCard(let token):
                let method = "POST"
                return ("/sender/payment_method/", ["payment_method_nonce": token], true, method)
                
            case .GetQuote(let token):
                let point1 = OrderManager.sharedInstance.currentOrder.getPickupPositionGeoJSON()
                let point2 = OrderManager.sharedInstance.currentOrder.getDestinationPositionGeoJSON()
                
                let params = [
                    "pickup_position": point1,
                    "destination_position": point2
                ]
                return ("/sender/order/quote/", params, false, "POST")
                
            case .GetOrderList(let page):
                let params = [
                    "page": page,
                    "page_size": Config.historyPageSize,
                    "status": "closed" as NSString
                ]
                return ("/sender/order/", params, true, "GET")
                
            case .CancelOrder(let pk, let params):
                return ("/sender/order/\(pk)/cancel/", params, true, "POST")
                
            case .RepublishOrder(let pk):
                return ("/sender/order/\(pk)/repost/", nil, true, "POST")
            
            case .AddAPNSToken(let token):
                let params = [
                    "apns_token": token,
                    "device_id": UIDevice.currentDevice().identifierForVendor!.UUIDString
                ]
                return ("/sender/ios_device/", params, true, "POST")
                
            case .Login(let phone, let password):
                let params = [
                    "phone": phone,
                    "password": password
                ]
                return ("/sender/account/login/", params, false, "POST")
                
            case .ChangePassword(let oldPassword, let newPassword):
                let params = [
                    "old_password": oldPassword,
                    "new_password": newPassword
                ]
                return ("/common/account/password_change/", params, true, "POST")
                
            case .ChangePersonalInfo(let firstName, let lastName):
                let params = [
                    "first_name": firstName,
                    "last_name": lastName
                ]
                return ("/sender/account/", params, true, "PUT")
                
            case .Logout():
                let params = [
                    "ios_device_id": UIDevice.currentDevice().identifierForVendor!.UUIDString
                ]
                return ("/common/account/logout/", params, true, "POST")
                
            case .GetOrderDetails(let pk):
                return ("/sender/order/\(pk)/", nil, true, "GET")
                
            case .GetActiveOrderDetails():
                return ("/sender/order/active/", nil, true, "GET")

            case .BindPhone(let phone):
                var params = Dictionary<String, AnyObject>()
                if phone != nil {
                    params["phone"] = phone
                }
                return ("/common/account/phone/request/", params, true, "POST")
                
            case .ConfirmPhone(let code):
                let params = ["code": code]
                return ("/common/account/phone/confirm/", params, true, "POST")

            case .Register(let firstName, let lastName, let phone, let password):
                let params = [
                        "phone": phone,
                        "password": password,
                        "first_name": firstName,
                        "last_name": lastName
                ]
                return ("/sender/account/signup/", params, false, "POST")
            
            case .GetBraintreeToken():
                return ("/sender/payment_method/client_token/", nil, true, "GET")
            
            case .GetPlaceAutosuggestions(let searchQuery, let lat, let lng):
                let params = [
                    "input": searchQuery,
                    "location": "\(lat),\(lng)"
                ]
                return ("/sender/autocomplete/address/", params, AuthManager.sharedInstance.isLoggedIn(), "GET")
                
            case .RestorePassword(let phone):
                let params = [
                    "phone": phone
                ]
                return ("/sender/account/password_reset/request/", params, false, "POST")
                
            case .RestorePasswordConfirm(let phone, let code, let password):
                var params = [
                    "phone": phone,
                    "code": code
                ]
                
                if password != nil {
                    params["password"] = password!
                }
                
                return ("/sender/account/password_reset/confirm/", params, false, "POST")
                
            case .GetNearbyCouriers(let northeast, let southwest):
                let params = [
                    "northeast": "\(northeast.latitude),\(northeast.longitude)",
                    "southwest": "\(southwest.latitude),\(southwest.longitude)",
                ]
                return ("/sender/couriers_available/", params, false, "GET")
                
            case .DeletePaymentMethod(let pk):
                return ("/sender/payment_method/\(pk)/", nil, true, "DELETE")
                
            case UpdatePaymentMethod(let token, let expMonth, let expYear, let verificationValue):
                let params = [
                    "expiration_month": expMonth,
                    "expiration_year": expYear,
                    "cvv": verificationValue
                ]
                return ("/sender/payment_method/\(token)/", params, true, "PUT")
                
            case MakePaymentMethodDefault(let token):
                let params = [
                    "make_default": "true"
                ]
                return ("/sender/payment_method/\(token)/", params, true, "PUT")
            }
        }()
        
        let URL = NSURL(string: Config.domainWithScheme + Config.APIVersionPrefix)!
        let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(result.path))

        if result.addAuthToken {
            URLRequest.setValue("JWT " + AuthManager.sharedInstance.authToken!, forHTTPHeaderField:"Authorization")
        }
        
        URLRequest.HTTPMethod = result.method
        
        var encoding = Alamofire.ParameterEncoding.JSON
        if ["GET", "HEAD", "DELETE"].contains(result.method) {
            encoding = Alamofire.ParameterEncoding.URL
        }
        
        return encoding.encode(URLRequest, parameters: result.parameters).0
    }
}