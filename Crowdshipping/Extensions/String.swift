//
//  String+urlEncode.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 09/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation

extension String {
    func urlEncode() -> String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
    }
    
    func toNumber() -> NSNumber? {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.decimalSeparator = "."
        return formatter.numberFromString(self)
    }
}