//
//  CourierModel.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 31/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

public class CourierModel: NSObject, Mappable {
    var firstName: String?
    var lastName: String?
    var tail: [CourierPositionModel]?
    var phone: String?
    var photo: String?

    // MARK: mappable
    
    required convenience public init?(_ map: Map) {
        self.init()
        mapping(map)
    }
    
    public func mapping(map: Map) {
        firstName       <- map["first_name"]
        lastName        <- map["last_name"]
        tail            <- map["track_tail"]
        
        phone           <- map["phone"]
        photo           <- map["photo"]
    }
}
