//
//  CoreDataLocalStorage.swift
//  DataKernel
//
//  Created by Denis Malykh on 30/04/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import Foundation
import CoreData

open class CoreDataLocalStorage: Storage {
    
    // MARK: - Storage
    
    internal let store: StoreRef
    internal let migration: Bool
    
    open var uiContext: Context!
    
    open func perform(_ ephemeral: Bool, unitOfWork: @escaping (_ context: Context, _ save: () -> Void) throws -> Void) throws {
        let context: NSManagedObjectContext = acquireSaveContext(ephemeral) as! NSManagedObjectContext
        var _error: Error!
        
        context.performAndWait {
            do {
                try unitOfWork(context, { () -> Void  in
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
            NotificationCenter.default.removeObserver(context)
        }
        
        if let error = _error {
            throw error
        }
    }
    
    open func performAsync(_ ephemeral: Bool, unitOfWork: @escaping (_ context: Context, _ save: () -> Void) throws -> Void) throws {
        let context: NSManagedObjectContext = acquireSaveContext(ephemeral) as! NSManagedObjectContext
        var _error: Error!
        
        context.perform {
            do {
                try unitOfWork(context, { () -> Void in
                    do {
                        try context.save(recursively: true)
                    } catch {
                        _error = error
                    }
                })
            } catch {
                _error = error
            }
        }
        
        if ephemeral {
            NotificationCenter.default.removeObserver(context)
        }
        
        if let error = _error {
            throw error
        }
    }
    
    open func wipeStore() throws {
        var _error: Error!
        
        persistentStoreCoordinator.performAndWait({
            do {
                try self.persistentStoreCoordinator.remove(self.persistentStore)
            } catch {
                _error = error
            }
        })
        
        if let error = _error {
            throw error
        }
        
        try FileManager.default.removeItem(at: store.location() as URL)
    }
    
    open func restoreStore() throws {        
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
        self.rootContext = initializeContext(.coordinator(self.persistentStoreCoordinator), concurrency: .privateQueueConcurrencyType)
        self.uiContext = initializeContext(.context(self.rootContext), concurrency: .mainQueueConcurrencyType)
    }
    
    // MARK: - Private
    
    internal var saveContext: Context!
    
    fileprivate func acquireSaveContext(_ ephemeral: Bool) -> Context! {
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
    
    fileprivate func initializeSaveContext() -> Context! {
        let context = initializeContext(.context(self.rootContext), concurrency: .privateQueueConcurrencyType)
        context.observeDidSaveNotification(true) { [weak self] (notification) -> Void in
            (self?.uiContext as? NSManagedObjectContext)?.mergeChanges(fromContextDidSave: notification)
        }
        return context
    }
    
    fileprivate func initializeContext(_ parent: ContextRef?, concurrency: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: concurrency)

        if let parent = parent {
            switch parent {
            case .context(let parentContext): context.parent = parentContext
            case .coordinator(let storeCoordinator): context.persistentStoreCoordinator = storeCoordinator
            }
        }
        
        context.observeToGetPermanentIDsBeforeSaving()
        
        return context
    }
    
    fileprivate func initializeStore(_ store: StoreRef, coordinator: NSPersistentStoreCoordinator, migrate: Bool) throws -> NSPersistentStore {
        try checkStorePath(store)
        let options = migrate ? OptionRef.migration : OptionRef.default
        return try addStore(store, coordinator: coordinator, options: options.build())
    }

    fileprivate func checkStorePath(_ store: StoreRef) throws {
        let path = store.location().deletingLastPathComponent()
        try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
    }

    fileprivate func addStore(_ store: StoreRef, coordinator: NSPersistentStoreCoordinator, options: [AnyHashable: Any], retry: Bool = true) throws -> NSPersistentStore {
        var pstore: NSPersistentStore?
        var error: NSError?
        
        coordinator.performAndWait({
            do {
                pstore = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: store.location() as URL, options: options)
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
        
        throw DkErrors.persistentStoreInitilization
    }
    
    fileprivate func cleanStoreOnFailedMigration(_ store: StoreRef) throws {
        let rawUrl: String = store.location().absoluteString
        let shmSidecar: URL = URL(string: rawUrl + "-shm")!
        let walSidecar: URL = URL(string: rawUrl + "-wal")!
        try FileManager.default.removeItem(at: store.location() as URL)
        try FileManager.default.removeItem(at: shmSidecar)
        try FileManager.default.removeItem(at: walSidecar)
    }


}
