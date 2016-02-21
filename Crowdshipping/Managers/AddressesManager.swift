//
//  AddressesManager.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 25/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation
import CoreData

public class AddressesManager : NSObject {
    public class var sharedInstance : AddressesManager {
        struct Static {
            static let instance : AddressesManager = AddressesManager()
        }
        return Static.instance
    }
    
    private func cleanForAddressType(type: MapVC.MapType) {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let request = NSFetchRequest(entityName: "LastUsedAddress")

        let pred = NSPredicate(format: "type == %@", type.rawValue)
        request.predicate = pred
        
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        var array: [AnyObject]?
        do {
            array = try context.executeFetchRequest(request)
        } catch let error as NSError  {
            Utils.log("Context error \(error), \(error.userInfo)")
            return
        }
        if array!.count > Config.maxLastAddressCount {
            for i in Config.maxLastAddressCount ..< array!.count {
                let entity = array![i] as! NSManagedObject
                context.deleteObject(entity)
            }
        }
        
        context.extendedSave()
    }
    
    private func checkIfAddressExists(address: String, type: MapVC.MapType) -> Bool {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let request = NSFetchRequest(entityName: "LastUsedAddress")
        
        let pred = NSPredicate(format: "type == %@ AND address ==[c] %@", type.rawValue, address)
        request.predicate = pred
        
        var array: [AnyObject]?
        do {
            array = try context.executeFetchRequest(request)
        } catch let error as NSError  {
            Utils.log("Context error \(error), \(error.userInfo)")
            return false
        }
        
        return array!.count > 0
    }
    
    func addAddress(address: String, date: NSDate, type: MapVC.MapType, coordinate: CLLocationCoordinate2D) {
        if checkIfAddressExists(address, type: type) {
            return
        }
        
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        var entity = NSEntityDescription.insertNewObjectForEntityForName("LastUsedAddress",
            inManagedObjectContext: context) as! LastUsedAddress
        
        entity.address = address
        entity.date = date
        entity.type = type.rawValue
        entity.lat = NSNumber(double: coordinate.latitude)
        entity.lng = NSNumber(double: coordinate.longitude)
        
        context.extendedSave()
    }
    
    func cleanIfNeeded() {
        cleanForAddressType(MapVC.MapType.Pickup)
        cleanForAddressType(MapVC.MapType.Destination)
    }
    
    func addCurrentOrderAddresses() {
        let currentOrder = OrderManager.sharedInstance.currentOrder
        addAddress(currentOrder.pickupAddress!, date:  NSDate(), type: MapVC.MapType.Pickup, coordinate: currentOrder.pickupPosition!)
        addAddress(currentOrder.destinationAddress!, date:  NSDate(), type: MapVC.MapType.Destination, coordinate: currentOrder.destinationPosition!)
        cleanIfNeeded()
    }
    
    func getLastAddressesForType(type: MapVC.MapType) -> [LastUsedAddress] {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let request = NSFetchRequest(entityName: "LastUsedAddress")
        
        let pred = NSPredicate(format: "type == %@", type.rawValue)
        request.predicate = pred
        
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        var array: [AnyObject]?
        do {
            array = try context.executeFetchRequest(request)
        } catch let error as NSError  {
            Utils.log("Context error \(error), \(error.userInfo)")
            return []
        }
        
        return array as! [LastUsedAddress]
    }
}
    