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
import MapKit


// These test use OHHTTPStubs and deprecated
class MockedAPITests: XCTestCase {
    
    override func setUp() {
        super.setUp()


    }
    
    override func tearDown() {
        //OHHTTPStubs.removeAllStubs()
        
        super.tearDown()
    }
 
    /*
    func prepareOrder() {
        AuthManager.sharedInstance.login("123")
    
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
        
        OrderManager.sharedInstance.currentOrder.pickupPhone = "+6598804321"
        OrderManager.sharedInstance.currentOrder.destinationPhone = "+6598804324"
        
        OrderManager.sharedInstance.currentOrder.orderSize = .Small
    }
    
    func testMakeOrder() {
        OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> Bool in
            let urlString = request.URL.absoluteString! as NSString
            let partToMatch = Config.APIVersionPrefix + "/sender/order/" as NSString
            let rng = urlString.rangeOfString(partToMatch)
            let matched = rng.location != NSNotFound
            
            return matched
            }, withStubResponse:( { (request: NSURLRequest!) -> OHHTTPStubsResponse in
                let jsonString = "{\"pickup_address\":\"Centennial Tower Singapore\",\"pickup_phone\":\"+6598804321\",\"destination_address\":\"Zott\'s Amoy Street Singapore\",\"destination_phone\":\"+6598804324\",\"size\":\"SMALL\",\"pickup_position\":{\"coordinates\":[103.860431,1.293346],\"type\":\"Point\"},\"destination_position\":{\"coordinates\":[103.847395,1.281372],\"type\":\"Point\"},\"note\":\"\",\"id\":14,\"state\":\"NEW\",\"courier\":null,\"price\":\"8.07\",\"estimated_pickup_interval\":null,\"estimated_delivery_interval\":null,\"created\":\"2015-03-02T14:24:47.826816Z\",\"modified\":\"2015-03-02T14:24:47.827742Z\",\"events\":[]}";
                
                return OHHTTPStubsResponse(data:jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false),
                    statusCode: 200, headers: ["Content-Type" : "text/json"])
            }))
        
        let expectation = expectationWithDescription("makeOrder")
        
        self.prepareOrder()
        
        APIManager.sharedInstance.makeOrder({ (json) -> Void in
            expectation.fulfill()
            
            XCTAssert(true, "makeOrder succeeded")
        }, failedCallback: { (json) -> Void in
            expectation.fulfill()
            
            XCTFail("makeOrder failed")
        })
        
        waitForExpectationsWithTimeout(30) { (error) in
            OHHTTPStubs.removeAllStubs()
        }
    }
    
    func testMakeOrderPaymentFailed() {
        let expectation = expectationWithDescription("testMakeOrderPaymentFailed")
        
        self.prepareOrder()
        
        OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> Bool in
            let urlString = request.URL.absoluteString! as NSString
            let partToMatch = Config.APIVersionPrefix + "/sender/order/" as NSString
            let rng = urlString.rangeOfString(partToMatch)
            let matched = rng.location != NSNotFound
            
            return matched
            }, withStubResponse:( { (request: NSURLRequest!) -> OHHTTPStubsResponse in
                let jsonString = "{\"code\": \"payment_error\", \"detail\": \"This is a test.\" }";
                
                return OHHTTPStubsResponse(data:jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false),
                    statusCode: 400, headers: ["Content-Type" : "text/json"])
            }))
        
        APIManager.sharedInstance.makeOrder({ (json) -> Void in
                expectation.fulfill()
                XCTFail("testMakeOrderPaymentFailed succeeded")
            }, failedCallback: { (json) -> Void in
                expectation.fulfill()
                if let code = json?["code"] as? String {
                    if contains(["no_payment_method", "payment_error"], code) {
                        XCTAssert(true, "testMakeOrderPaymentFailed failed with proper error code")
                        return
                    }
                }
                
                XCTFail("testMakeOrderPaymentFailed failed with bad error code")
        })
        
        waitForExpectationsWithTimeout(30) { (error) in OHHTTPStubs.removeAllStubs() }
    }
    */
}
