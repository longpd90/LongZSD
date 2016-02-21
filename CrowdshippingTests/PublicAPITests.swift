//
//  PublicAPITests.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 27/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit
import XCTest
import Crowdshipping
import MapKit

class PublicAPITests: XCTestCase {

    func testLogin() {
        let expectation = expectationWithDescription("APIManager login")
        
        APIManager.sharedInstance.login("ppp@ppp.ru", password: "123456",
            successCallback: ({ () -> Void in
                expectation.fulfill()
                XCTAssert(true, "login succeeded")
            }),
            failedCallback: ({ (json) -> Void in
                expectation.fulfill()
                
                XCTFail("login failed")
            }))
        
        waitForExpectationsWithTimeout(30) { (error) in
            
        }
    }
    
    func testGetQuote() {
        let expectation = expectationWithDescription("APIManager login")
        
        OrderManager.sharedInstance.currentOrder.pickupAddress          = "141 Serangoon Rd"
        OrderManager.sharedInstance.currentOrder.destinationAddress     = "141A Lorong 2 Toa Payoh"
        
        OrderManager.sharedInstance.currentOrder.pickupPosition         = CLLocationCoordinate2D(
            latitude: 1.307792,
            longitude: 103.852583
        )
        
        OrderManager.sharedInstance.currentOrder.destinationPosition    = CLLocationCoordinate2D(
            latitude: 1.335212,
            longitude: 103.84559
        )
        
        APIManager.sharedInstance.getQuote({ (json) -> Void in
            expectation.fulfill()
            
            XCTAssert(true, "get quote succeeded")
            }, failedCallback: { (json) -> Void in
                expectation.fulfill()
                
                XCTFail("get quote failed")
        })
        
        waitForExpectationsWithTimeout(30) { (error) in
            
        }
    }
    
    /*
    func testAddAPNSToken() {
        let expectation = expectationWithDescription("APIManager addAPNSToken")

        APIManager.sharedInstance.addAPNSToken("123",
            successCallback: { (json) -> Void in
                expectation.fulfill()
                
                XCTAssert(true, "addAPNSToken succeeded")
            }) { (json) -> Void in
                expectation.fulfill()
                
                XCTFail("addAPNSToken failed")
        }
        
        waitForExpectationsWithTimeout(30) { (error) in
            
        }
    }
*/
}
