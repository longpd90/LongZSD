//
//  NSManagedObjectContext.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 25/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func extendedSave() {
        do {
            try self.save()
        } catch let error as NSError {
            Utils.log("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func extendedExecuteFetchRequest(request: NSFetchRequest) -> [NSManagedObject]? {
        var array: AnyObject?
        do {
            array = try self.executeFetchRequest(request)
        } catch let error as NSError {
            Utils.log("Context error \(error), \(error.userInfo)")
        }
        
        return array as? [NSManagedObject]
    }
    
    func removeAllEntitiesOfType(entityType: String) {
        let fetchRequest = NSFetchRequest(entityName: entityType)
        fetchRequest.includesPropertyValues = false
        
        if let objects = self.extendedExecuteFetchRequest(fetchRequest) {
            for obj in objects {
                self.deleteObject(obj)
            }
            
            self.extendedSave()
        }
    }
}