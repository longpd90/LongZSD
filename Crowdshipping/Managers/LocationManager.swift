//
//  AuthManager.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 16/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation

public class LocationManager : NSObject, CLLocationManagerDelegate {

    var coreLocationLocationManager : CLLocationManager = CLLocationManager()
    var lastLocation : CLLocation?
    
    public class var sharedInstance : LocationManager {
        struct Static {
            static let instance : LocationManager = LocationManager()
        }
        return Static.instance
    }
    
    func startUpdating () {
        coreLocationLocationManager.delegate = self
        coreLocationLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if coreLocationLocationManager.respondsToSelector(Selector("requestWhenInUseAuthorization")) {
            coreLocationLocationManager.requestWhenInUseAuthorization()
        }
        
        coreLocationLocationManager.startUpdatingLocation()
    }
    
    public func isAuthorized() -> Bool {
        let status = CLLocationManager.authorizationStatus()

        // TODO: change to .AuthorizedAlways when Travis-CI begin to support iOS SDK 8.2
        let authorizedAlways = CLAuthorizationStatus(rawValue: 3)
        
        return status == authorizedAlways || status == .AuthorizedWhenInUse
    }
    
    // MARK: CLLocationManagerDelegate
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Utils.log("didUpdateLocations")
        
        lastLocation = locations.last as CLLocation?
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //Utils.log("didFailWithError")
    }
    
    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if isAuthorized() {
            coreLocationLocationManager.startUpdatingLocation()
        }
    }
}