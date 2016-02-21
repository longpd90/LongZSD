//
//  NSDate.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 10/04/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation

extension NSDate {
    func simpleFormat() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd H:mm"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        return dateFormatter.stringFromDate(self)
    }
}