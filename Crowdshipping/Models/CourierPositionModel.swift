//
//  CourierModel.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 31/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

public class CourierPositionModel: NSObject, Mappable {
    var timestamp: NSDate?
    var coordinate: CLLocationCoordinate2D?
    var course: Double?
    var speed: Double?
    
    // MARK: mappable
    
    required convenience public init?(_ map: Map) {
        self.init()
        mapping(map)
    }
    
    public func mapping(map: Map) {
        timestamp       <- (map["timestamp"], CustomTransforms.transformDate)
        coordinate      <- (map["position.coordinates"], CustomTransforms.transformCoordinate)
        course          <- map["course"]
        speed           <- map["speed"]
    }
}
