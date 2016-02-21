//
//  LastUsedAddress.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 25/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation
import CoreData

@objc(LastUsedAddress)

class LastUsedAddress: NSManagedObject {

    @NSManaged var address: String
    @NSManaged var date: NSDate
    @NSManaged var type: String
    @NSManaged var lat: NSNumber
    @NSManaged var lng: NSNumber

}
