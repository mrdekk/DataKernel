//
//  NSManagedObjectContext.swift
//  DataKernel
//
//  Created by Denis Malykh on 01/05/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext: Context {
    
    // MARK: - Context
    
    public func fetch<E: Entity>(request: Request<E>) throws -> [E] {
        return try fetchImpl(request, includeProps: true)
    }
    
    public func create<E: Entity>() throws -> E {
        guard let entityClass = E.self as? NSManagedObject.Type else {
            throw DkErrors.InvalidEntityClass
        }

        let object = NSEntityDescription.insertNewObjectForEntityForName(entityClass.entityName, inManagedObjectContext: self)
        if let inserted = object as? E {
            return inserted
        } else {
            throw DkErrors.InvalidEntityClass
        }

    }
    
    // TODO: may be it will be very usefull to fill the values of created entity with what is supplied to condition, but condition may be oneOf or anything
    public func acquire<E: Entity>(condition: Request<E>) throws -> E {
        let fetched = try fetch(condition)
        if fetched.count > 0 {
            if let entity = fetched.first {
                return entity
            }
        }
        
        return try create()
    }
    
    public func remove<E: Entity>(entity: E) throws {
        try remove([entity])
    }
    
    public func remove<E: Entity>(entities: [E]) throws {
        for entity in entities {
            guard let entity = entity as? NSManagedObject else {
                continue
            }
            
            deleteObject(entity)
        }
    }
    
    public func remove<E: Entity>(condition: Request<E>) throws {
        let entities = try fetchImpl(condition, includeProps: false)
        try remove(entities)
    }
    
    public func wipe<E: Entity>(type: E.Type) throws {
        let request = Request<E>(sort: nil, predicate: nil)
        let entities = try fetchImpl(request, includeProps: false)
        try remove(entities)
    }
    
    
    // MARK: - Special things
    
    func save(recursively recursively: Bool) throws {
        var _error: ErrorType!
        
        performBlockAndWait {
            if self.hasChanges {
                do {
                    try self.saveThisAndParentContext(recursively)
                } catch {
                    _error = error
                }
            }
        }
        
        if let error = _error {
            throw error
        }
    }
    
    // MARK: - Observing things
    
    func observeToGetPermanentIDsBeforeSaving() {
        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextWillSaveNotification, object: self, queue: nil, usingBlock: { [weak self] (notification) in
            guard let strongSelf = self else {
                return
            }
            if strongSelf.insertedObjects.count == 0 {
                return
            }
            _ = try? strongSelf.obtainPermanentIDsForObjects(Array(strongSelf.insertedObjects))
        })
    }
    
    func observeDidSaveNotification(inMainThread: Bool, saveNotification: (notification: NSNotification) -> Void) {
        let queue: NSOperationQueue = inMainThread ? NSOperationQueue.mainQueue() : NSOperationQueue()
        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: self, queue: queue, usingBlock: saveNotification)
    }
    
    // MARK: - Private
    
    func saveThisAndParentContext(recursively: Bool) throws {
        try save()
        
        if recursively {
            if let parent = parentContext {
                try parent.save(recursively: recursively)
            }
        }
    }
    
    func buildNSFetchRequest<E: Entity>(request: Request<E>) throws -> NSFetchRequest {
        guard let entityClass = E.self as? NSManagedObject.Type else {
            throw DkErrors.InvalidEntityClass
        }
        
        return buildNSFetchRequest(entityClass.entityName, predicate: request.predicate, sort: request.sort)
    }
    
    func buildNSFetchRequest(entityName: String, predicate: NSPredicate?, sort: NSSortDescriptor?) -> NSFetchRequest {
        let request = NSFetchRequest(entityName: entityName)
        
        if let predicate = predicate {
            request.predicate = predicate
        }
        
        if let sort = sort {
            request.sortDescriptors = [sort]
        }
        
        return request
    }
    
    func fetchImpl<E: Entity>(request: Request<E>, includeProps: Bool = true) throws -> [E] {
        let fetchRequest = try buildNSFetchRequest(request)
        fetchRequest.includesPropertyValues = includeProps
        
        let results = try self.executeFetchRequest(fetchRequest)
        return results.map {$0 as! E}
   }
}