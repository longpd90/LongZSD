//
//  CLLocationCoordinate2D.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 19/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {
    init?(array: Array<Double>) {
        if array.count != 2 {
            return nil
        }
        
        self.latitude = array[1]
        self.longitude = array[0]
        
        if !CLLocationCoordinate2DIsValid(self) {
            return nil
        }
    }

    init?(array: Array<String>) {
        if array.count != 2 {
            return nil
        }

        if let lat = array[1].toNumber()?.doubleValue {
            if let lng = array[0].toNumber()?.doubleValue {
                self.latitude = lat
                self.longitude = lng
                
                if !CLLocationCoordinate2DIsValid(self) {
                    return nil
                }
                
                return
            }
        }
        
        return nil
    }
}