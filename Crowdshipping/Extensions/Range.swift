//
//  Range.swift
//  Crowdshipping
//
//  Created by Ivan Kozlov on 26/05/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation

extension NSRange {
    func toRange(string: String) -> Range<String.Index> {
//        let startIndex = advance(string.startIndex, location)
        let startIndex = string.startIndex.advancedBy(location)
//        let endIndex = advance(startIndex, length)
        let endIndex = startIndex.advancedBy(length)
        return startIndex..<endIndex
    }
}
