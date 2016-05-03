//
//  CoreDataLocalStorage.swift
//  DataKernel
//
//  Created by Denis Malykh on 30/04/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataLocalStorage: Storage {
    
    // MARK: - Storage
    
    internal let store: StoreRef
    internal let migration: Bool
    
    public var uiContext: Context!
    
    public func perform(ephemeral: Bool, unitOfWork: (context: Context, save: () -> Void) throws -> Void) throws {
        let context: NSManagedObjectContext = acquireSaveContext(ephemeral) as! NSManagedObjectContext
        var _error: ErrorType!
        
        context.performBlockAndWait {
            do {
                try unitOfWork(context: context, save: { () -> Void  in
                    do {
                        try context.save(recursively: true)
                    }
                    catch {
                        _error = error
                    }
                })
            } catch {
                _error = error
            }
        }
        
        if ephemeral {
            NSNotificationCenter.defaultCenter().removeObserver(context)
        }
        
        if let error = _error {
            throw error
        }
    }
    
    public func wipeStore() throws {
        var _error: ErrorType!
        
        persistentStoreCoordinator.performBlockAndWait({
            do {
                try self.persistentStoreCoordinator.removePersistentStore(self.persistentStore)
            } catch {
                _error = error
            }
        })
        
        if let error = _error {
            throw error
        }
        
        try NSFileManager.defaultManager().removeItemAtURL(store.location())
    }
    
    public func restoreStore() throws {        
        self.persistentStore = try initializeStore(store, coordinator: self.persistentStoreCoordinator, migrate: self.migration)
    }
    
    // MARK: - Props
    
    internal var model: NSManagedObjectModel! = nil
    internal var persistentStore: NSPersistentStore! = nil
    internal var persistentStoreCoordinator: NSPersistentStoreCoordinator! = nil
    internal var rootContext: NSManagedObjectContext! = nil
    
    // MARK: - Init
    
    public init(store: StoreRef, model: ModelRef, migration: Bool) throws {
        self.store = store
        self.migration = migration
        
        self.model = model.build()!
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        self.persistentStore = try initializeStore(store, coordinator: self.persistentStoreCoordinator, migrate: migration)
        self.rootContext = initializeContext(.Coordinator(self.persistentStoreCoordinator), concurrency: .PrivateQueueConcurrencyType)
        self.uiContext = initializeContext(.Context(self.rootContext), concurrency: .MainQueueConcurrencyType)
    }
    
    // MARK: - Private
    
    internal var saveContext: Context!
    
    private func acquireSaveContext(ephemeral: Bool) -> Context! {
        if ephemeral {
            return initializeSaveContext()
        } else {
            if let context = self.saveContext {
                return context
            }
            
            self.saveContext = initializeSaveContext()
            return saveContext
        }
    }
    
    private func initializeSaveContext() -> Context! {
        let context = initializeContext(.Context(self.rootContext), concurrency: .PrivateQueueConcurrencyType)
        context.observeDidSaveNotification(true) { [weak self] (notification) -> Void in
            (self?.uiContext as? NSManagedObjectContext)?.mergeChangesFromContextDidSaveNotification(notification)
        }
        return context
    }
    
    private func initializeContext(parent: ContextRef?, concurrency: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: concurrency)

        if let parent = parent {
            switch parent {
            case .Context(let parentContext): context.parentContext = parentContext
            case .Coordinator(let storeCoordinator): context.persistentStoreCoordinator = storeCoordinator
            }
        }
        
        context.observeToGetPermanentIDsBeforeSaving()
        
        return context
    }
    
    private func initializeStore(store: StoreRef, coordinator: NSPersistentStoreCoordinator, migrate: Bool) throws -> NSPersistentStore {
        try checkStorePath(store)
        let options = migrate ? OptionRef.Migration : OptionRef.Default
        return try addStore(store, coordinator: coordinator, options: options.build())
    }

    private func checkStorePath(store: StoreRef) throws {
        if let path = store.location().URLByDeletingLastPathComponent {
            try NSFileManager.defaultManager().createDirectoryAtURL(path, withIntermediateDirectories: true, attributes: nil)
        }
    }

    private func addStore(store: StoreRef, coordinator: NSPersistentStoreCoordinator, options: [NSObject: AnyObject], retry: Bool = true) throws -> NSPersistentStore {
        var pstore: NSPersistentStore?
        var error: NSError?
        
        coordinator.performBlockAndWait({
            do {
                pstore = try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: store.location(), options: options)
            } catch let _error as NSError {
                error = _error
            }
        })
        
        if let error = error {
            let errorOnMigration = error.code == NSPersistentStoreIncompatibleVersionHashError || error.code == NSMigrationMissingSourceModelError
            if errorOnMigration && retry {
                try cleanStoreOnFailedMigration(store)
                return try addStore(store, coordinator: coordinator, options: options, retry: false)
            } else {
                throw error
            }
        } else if let pstore = pstore {
            return pstore
        }
        
        throw DkErrors.PersistentStoreInitilization
    }
    
    private func cleanStoreOnFailedMigration(store: StoreRef) throws {
        let rawUrl: String = store.location().absoluteString
        let shmSidecar: NSURL = NSURL(string: rawUrl.stringByAppendingString("-shm"))!
        let walSidecar: NSURL = NSURL(string: rawUrl.stringByAppendingString("-wal"))!
        try NSFileManager.defaultManager().removeItemAtURL(store.location())
        try NSFileManager.defaultManager().removeItemAtURL(shmSidecar)
        try NSFileManager.defaultManager().removeItemAtURL(walSidecar)
    }


}
