//
//  CourierModel.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 31/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

public class CourierTrackModel: NSObject, Mappable {
    var id: Int?
    var tail: [CourierPositionModel]?
    var pin: GMSMarker? = nil
    
    // MARK: mappable
    
    required public init?(_ map: Map) {
        super.init()
        mapping(map)
    }
    
    public func mapping(map: Map) {
        tail            <- map["track_tail"]
        id              <- map["id"]
    }
}
