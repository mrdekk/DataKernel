//
//  CoreDataLocalStoreTests.swift
//  DataKernel
//
//  Created by Denis Malykh on 02/05/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import XCTest
import CoreData
@testable import DataKernel

class CoreDataLocalStoreTests: XCTestCase {

    var store: StoreRef?
    var model: ModelRef?
    var storage: CoreDataLocalStorage?
    
    override func setUp() {
        super.setUp()

        store = .Named("test1")
        let bundle = NSBundle(forClass: self.classForCoder)
        model = .Merged([bundle])
        self.storage = try! CoreDataLocalStorage(store: store!, model: model!, migration: true)
    }
    
    override func tearDown() {
        _ = try? storage?.wipeStore()

        super.tearDown()
    }
    
    func testStoreCreation() {
        let path = store!.location().path!
        
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(path))
    }
    
    func testRootContext() {
        XCTAssertEqual(storage?.rootContext.persistentStoreCoordinator, storage?.persistentStoreCoordinator)
        XCTAssertEqual(storage?.rootContext.concurrencyType, .PrivateQueueConcurrencyType)
    }

    func testSaveContext() {
        var saveContext: Context!
        try! storage?.perform(true, unitOfWork: { (context, save) -> Void in
            saveContext = context
        })
        
        XCTAssertEqual((saveContext as! NSManagedObjectContext).parentContext, storage?.rootContext)
        XCTAssertEqual((saveContext as! NSManagedObjectContext).concurrencyType, NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
    }
    
    func testUIContext() {
        XCTAssertEqual((storage?.uiContext as! NSManagedObjectContext).parentContext, storage?.rootContext)
        XCTAssertEqual((storage?.uiContext as! NSManagedObjectContext).concurrencyType, NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    }
    
    func testStoreRemoval() {
        _ = try? storage?.wipeStore()
        let path = store!.location().path!
        
        XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(path))
    }

    func testSave() {
        _ = try? storage?.perform(true, unitOfWork: { (context, save) -> Void in
            let _: Car = try! context.create()
            save()
        })
        let request: DataRequest<Car> = DataRequest()
        let carsCount: Int? = try! storage?.uiContext.fetch(request).count
        
        XCTAssertEqual(carsCount, 1)
    }
}
