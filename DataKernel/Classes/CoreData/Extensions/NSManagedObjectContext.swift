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
    
    public func fetch<E>(_ request: Request<E>) throws -> [E] {
        return try fetchImpl(request, includeProps: true)
    }
    
    public func count<E>(_ request: Request<E>) throws -> Int {
        let entities = try fetchImpl(request, includeProps: false)
        return entities.count
    }
    
    public func create<E: Entity>() throws -> E {
        guard let entityClass = E.self as? NSManagedObject.Type else {
            throw DkErrors.invalidEntityClass
        }

        let object = NSEntityDescription.insertNewObject(forEntityName: entityClass.entityName, into: self)
        if let inserted = object as? E {
            return inserted
        } else {
            throw DkErrors.invalidEntityClass
        }

    }
    
    // TODO: may be it will be very usefull to fill the values of created entity with what is supplied to condition, but condition may be oneOf or anything
    public func acquire<E: Entity>(_ value: Any) throws -> E {
        let pk = try pkKey(E.self)
        let condition = Request<E>().filtered(pk, equalTo: value)
        let fetched = try fetch(condition)
        if fetched.count > 0 {
            if let entity = fetched.first {
                return entity
            }
        }
        
        let entity: E = try create()
        if let entity: NSManagedObject = entity as? NSManagedObject {
            entity.setValue(value, forKey: pk)
        }
        
        return entity
    }
    
    public func remove<E: Entity>(_ entity: E) throws {
        try remove([entity])
    }
    
    public func remove<E: Entity>(_ entities: [E]) throws {
        for entity in entities {
            guard let entity = entity as? NSManagedObject else {
                continue
            }
            
            delete(entity)
        }
    }
    
    public func remove<E>(_ condition: Request<E>) throws {
        let entities = try fetchImpl(condition, includeProps: false)
        try remove(entities)
    }
    
    public func wipe<E: Entity>(_ type: E.Type) throws {
        if #available(iOS 9, OSX 10.11, *) {
            guard let entityClass = E.self as? NSManagedObject.Type else {
                throw DkErrors.invalidEntityClass
            }
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityClass.entityName)
            let requestDelete = NSBatchDeleteRequest(fetchRequest: request)
            try execute(requestDelete)
        } else {
            let request = Request<E>(sort: nil, predicate: nil)
            let entities = try fetchImpl(request, includeProps: false)
            try remove(entities)
        }
    }
    
    
    // MARK: - Special things
    
    func save(recursively: Bool) throws {
        var _error: Error!
        
        performAndWait {
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
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextWillSave, object: self, queue: nil, using: { [weak self] (notification) in
            guard let strongSelf = self else {
                return
            }
            if strongSelf.insertedObjects.count == 0 {
                return
            }
            _ = try? strongSelf.obtainPermanentIDs(for: Array(strongSelf.insertedObjects))
        })
    }
    
    func observeDidSaveNotification(_ inMainThread: Bool, saveNotification: @escaping (_ notification: Notification) -> Void) {
        let queue: OperationQueue = inMainThread ? OperationQueue.main : OperationQueue()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: self, queue: queue, using: saveNotification)
    }
    
    // MARK: - Private
    
    func saveThisAndParentContext(_ recursively: Bool) throws {
        try save()
        
        if recursively {
            if let parent = parent {
                try parent.save(recursively: recursively)
            }
        }
    }
    
    func buildNSFetchRequest<E>(_ request: Request<E>) throws -> NSFetchRequest<NSFetchRequestResult> {
        guard let entityClass = E.self as? NSManagedObject.Type else {
            throw DkErrors.invalidEntityClass
        }
        
        return buildNSFetchRequest(entityClass.entityName, predicate: request.predicate, sort: request.sort)
    }
    
    func buildNSFetchRequest(_ entityName: String, predicate: NSPredicate?, sort: NSSortDescriptor?) -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        if let predicate = predicate {
            request.predicate = predicate
        }
        
        if let sort = sort {
            request.sortDescriptors = [sort]
        }
        
        return request
    }
    
    func fetchImpl<E>(_ request: Request<E>, includeProps: Bool = true) throws -> [E] {
        let fetchRequest = try buildNSFetchRequest(request)
        fetchRequest.includesPropertyValues = includeProps
        
        let results = try self.fetch(fetchRequest)
        return results.map {$0 as! E}
    }
    
    func pkKey<E: Entity>(_ type: E.Type) throws -> String {
        guard let entityClass = E.self as? NSManagedObject.Type else {
            throw DkErrors.invalidEntityClass
        }
        
        let desc: NSEntityDescription? = NSEntityDescription.entity(forEntityName: entityClass.entityName, in: self)
        guard let idesc: NSEntityDescription = desc else {
            throw DkErrors.invalidEntityClass
        }

        guard let pk = idesc.userInfo?["pk"] as? String else {
            assert(false, "to work with DataKernel entity should have pk info in userInfo")
            throw DkErrors.invalidEntityClass
        }
        
        let pkDesc = idesc.attributesByName[pk]
        guard let ipkDesc: NSAttributeDescription = pkDesc else {
            throw DkErrors.invalidEntityClass
        }

        if !ipkDesc.isIndexed {
            assert(false, "pk found (\(pk)) but it is not indexed, that will be huge performance problems")
        }

        return pk
    }
}
