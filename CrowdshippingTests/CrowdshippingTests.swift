//
//  CrowdshippingTests.swift
//  CrowdshippingTests
//
//  Created by Peter Prokop on 13/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit
import XCTest
import Crowdshipping

class CrowdshippingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

    func testISO8601Date() {
        let date = Utils.ISO8601ToDate("2015-03-05T14:25:20.737Z")

        XCTAssert(date?.timeIntervalSince1970 == 1425565520.737, "Date parsed successfully")
    }
    
}
