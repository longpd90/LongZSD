//
//  CustomTransforms.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 03/04/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

public struct CustomTransforms {
    static let transformCoordinate = TransformOf<CLLocationCoordinate2D, Array<Double> >(fromJSON: { (value: Array<Double>?) -> CLLocationCoordinate2D? in
        return value == nil ? nil : CLLocationCoordinate2D(array: value!)
        }, toJSON: { (value: CLLocationCoordinate2D?) -> Array<Double>? in
            if value == nil {
                return nil
            }
            
            return  [value!.longitude, value!.latitude]
    })
    
    static let transformDate = TransformOf<NSDate, String>(fromJSON: { (value: String?) -> NSDate? in
        return value == nil ? nil : Utils.ISO8601ToDate(value!)
        }, toJSON: { (value: NSDate?) -> String? in
            // TODO: implement
            return nil
    })
}