//
//  OrderModel.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 23/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation
import CoreLocation

public class OrderModel : NSObject, NSCoding, Mappable {
    public enum OrderSize : String {
        case
            Small = "SMALL",
            Medium = "MEDIUM",
            Large = "LARGE"
    }
    
    public enum OrderState : String {
        /*
        ('NEW', _('New')),
        # ('PAID', _('Paid')),
        ('CANCELLED', _('Cancelled')),
        # ('COURIER_CANCELLED', _('Courier Cancelled')),
        ('ACCEPTED', _('Accepted')),
        ('DELIVERY', _('Delivery')),
        ('COMPLETED', _('Completed')),
        # ('DELIVERY_FAILURE', _('Delivery Failure')),
        # ('RETURNED', _('Returned')),
        # ('LOST', _('Lost')),
        */
        
        case
            New = "NEW",
            Cancelled = "CANCELLED",
            Accepted = "ACCEPTED",
            Delivery = "DELIVERY",
            Completed = "COMPLETED",
            CourierCancelled = "COURIER_CANCELLED",
            AdminCancelled = "DELIVERY_FAILURE",
            Returning = "RETURNING",
            Returned = "RETURNED",
            InOffice = "IN_OFFICE"
    }
    
    public var pk : Int?
    
    public var pickupAddress : String?
    public var pickupAddressDetail : String?
    public var pickupPhone : String?
    
    public var destinationAddress : String?
    public var destinationAddressDetail : String?
    public var destinationPhone : String?
    
    public var paymentMethod : String?
    
    public var notes : String?
    
    public var pickupPosition : CLLocationCoordinate2D?
    public var destinationPosition : CLLocationCoordinate2D?
    
    // TODO: refactor pricesData
    var pricesData : Dictionary<String, AnyObject>?
    
    public var orderSize : OrderSize?
    public var price : Double?
    
    public var state: OrderState?
    
    public var courier: CourierModel?
    
    public var pickupConfirmationCode: String?
    public var deliveryConfirmationCode: String?
    
    public var created: NSDate?
    public var timerStarted: NSDate?
    public var timerFinished: NSDate?
    
    public var courierCancelReason: String?
    public var resolutionNote: String?
    public var returnDestination: String?
    
    override init() {
    }
    
    private class func convertToGeoJSON(coordinate: CLLocationCoordinate2D) -> String {
        return "{" +
            "\"type\": \"Point\"," +
            "\"coordinates\": [ \(coordinate.longitude), \(coordinate.latitude)]" +
        "}"
    }
    
    func getPickupPositionGeoJSON() -> String {
        return OrderModel.convertToGeoJSON(pickupPosition!)
    }
    
    func getDestinationPositionGeoJSON() -> String {
        return OrderModel.convertToGeoJSON(destinationPosition!)
    }
    
    // MARK: NSCoding
    
    required convenience public init(coder decoder: NSCoder) {
        self.init()
        self.pk = Int(decoder.decodeIntForKey("pk"))
        
        self.pickupAddress = decoder.decodeObjectForKey("pickupAddress") as? String
        self.pickupAddressDetail = decoder.decodeObjectForKey("pickup_address_detail") as? String
        self.pickupPhone = decoder.decodeObjectForKey("pickupPhone") as? String
        self.destinationAddress = decoder.decodeObjectForKey("destinationAddress") as? String
        self.destinationAddressDetail = decoder.decodeObjectForKey("destination_address_detail") as? String
        self.destinationPhone = decoder.decodeObjectForKey("destinationPhone") as? String
        
        self.paymentMethod = decoder.decodeObjectForKey("paymentMethod") as? String
        
        self.notes = decoder.decodeObjectForKey("notes") as? String
        
        self.pickupPosition = CLLocationCoordinate2DMake(decoder.decodeDoubleForKey("pickupLatitude"),
            decoder.decodeDoubleForKey("pickupLongitude"))
        
        self.destinationPosition = CLLocationCoordinate2DMake(decoder.decodeDoubleForKey("destinationLatitude"),
            decoder.decodeDoubleForKey("destinationLongitude"))
        
        self.orderSize = OrderSize(rawValue: decoder.decodeObjectForKey("orderSize") as! String)
        self.price = decoder.decodeDoubleForKey("price")
        
        self.state = OrderState(rawValue: decoder.decodeObjectForKey("state") as! String)
        
        self.timerStarted = decoder.decodeObjectForKey("timer_started") as? NSDate
        self.timerFinished = decoder.decodeObjectForKey("timer_finished") as? NSDate
        
        self.courierCancelReason = decoder.decodeObjectForKey("courier_cancel_reason") as? String
        self.resolutionNote = decoder.decodeObjectForKey("resolution_note") as? String
        self.returnDestination = decoder.decodeObjectForKey("return_destination") as? String
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeInt(Int32(pk!), forKey: "pk")
        
        coder.encodeObject(pickupAddress, forKey: "pickupAddress")
        coder.encodeObject(pickupAddressDetail, forKey: "pickup_address_detail")
        coder.encodeObject(pickupPhone, forKey: "pickupPhone")
        coder.encodeObject(destinationAddress, forKey: "destinationAddress")
        coder.encodeObject(destinationAddressDetail, forKey: "destination_address_detail")
        coder.encodeObject(destinationPhone, forKey: "destinationPhone")
        
        coder.encodeObject(paymentMethod, forKey: "payment_method")
        
        coder.encodeObject(notes, forKey: "notes")
        
        coder.encodeDouble(pickupPosition!.latitude, forKey: "pickupLatitude")
        coder.encodeDouble(pickupPosition!.longitude, forKey: "pickupLongitude")
        
        coder.encodeDouble(destinationPosition!.latitude, forKey: "destinationLatitude")
        coder.encodeDouble(destinationPosition!.longitude, forKey: "destinationLongitude")
        
        coder.encodeObject(orderSize!.rawValue, forKey: "orderSize")
        coder.encodeDouble(price!, forKey: "price")
        
        coder.encodeObject(state!.rawValue, forKey: "state")
        
        coder.encodeObject(timerStarted, forKey: "timer_started")
        coder.encodeObject(timerFinished, forKey: "timer_finished")
        
        coder.encodeObject(courierCancelReason, forKey: "courier_cancel_reason")
        coder.encodeObject(resolutionNote, forKey: "resolution_note")
        coder.encodeObject(returnDestination, forKey: "return_destination")
    }
    
    // MARK: mappable
    
    required convenience public init?(_ map: Map) {
        self.init()
        mapping(map)
    }
    
    public func mapping(map: Map) {
        // Transforms
        let transformState = TransformOf<OrderState, String>(fromJSON: { (value: String?) -> OrderState? in
            return value == nil ? nil : OrderState(rawValue: value!)
            }, toJSON: { (value: OrderState?) -> String? in
                value?.rawValue
        })
        
        let transformSize = TransformOf<OrderSize, String>(fromJSON: { (value: String?) -> OrderSize? in
            return value == nil ? nil : OrderSize(rawValue: value!)
            }, toJSON: { (value: OrderSize?) -> String? in
                value?.rawValue
        })
        
        let transformPrice = TransformOf<Double, String>(fromJSON: { (value: String?) -> Double? in
            return value == nil ? nil : value!.toNumber()?.doubleValue
        }, toJSON: { (value: Double?) -> String? in
            return value == nil ? nil : String(format:"%.2f", value!)
        })
        
        pk                  <- map["id"]

        pickupAddress       <- map["pickup_address"]
        pickupAddressDetail <- map["pickup_address_detail"]
        pickupPhone         <- map["pickup_phone"]
        
        destinationAddress  <- map["destination_address"]
        destinationAddressDetail <- map["destination_address_detail"]
        destinationPhone    <- map["destination_phone"]
        
        paymentMethod <- map["payment_method"]
        
        notes               <- map["note"]
        
        pickupPosition      <- (map["pickup_position.coordinates"], CustomTransforms.transformCoordinate)
        destinationPosition <- (map["destination_position.coordinates"], CustomTransforms.transformCoordinate)
        
        orderSize           <- (map["size"], transformSize)
        price               <- (map["price"], transformPrice)
        
        state               <- (map["state"], transformState)
        courier             <- map["courier"]
        
        pickupConfirmationCode      <- map["pickup_confirmation_code"]
        deliveryConfirmationCode    <- map["delivery_confirmation_code"]
        
        created                     <- (map["created"], CustomTransforms.transformDate)
        
        timerStarted <- (map["timer_started"], CustomTransforms.transformDate)
        timerFinished <- (map["timer_finished"], CustomTransforms.transformDate)
        
        courierCancelReason <- map["courier_cancel_reason"]
        resolutionNote <- map["resolution_note"]
        returnDestination <- map["return_destination"]
    }
}