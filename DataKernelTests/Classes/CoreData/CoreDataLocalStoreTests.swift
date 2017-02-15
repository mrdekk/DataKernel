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

        store = .named("test1")
        let bundle = Bundle(for: self.classForCoder)
        model = .merged([bundle])
        self.storage = try! CoreDataLocalStorage(store: store!, model: model!, migration: true)
    }
    
    override func tearDown() {
        _ = try? storage?.wipeStore()

        super.tearDown()
    }
    
    func testStoreCreation() {
        let path = store!.location().path
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))
    }
    
    func testRootContext() {
        XCTAssertEqual(storage?.rootContext.persistentStoreCoordinator, storage?.persistentStoreCoordinator)
        XCTAssertEqual(storage?.rootContext.concurrencyType, .privateQueueConcurrencyType)
    }

    func testSaveContext() {
        var saveContext: Context!
        try! storage?.perform(true, unitOfWork: { (context, save) -> Void in
            saveContext = context
        })
        
        XCTAssertEqual((saveContext as! NSManagedObjectContext).parent, storage?.rootContext)
        XCTAssertEqual((saveContext as! NSManagedObjectContext).concurrencyType, NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
    }
    
    func testUIContext() {
        XCTAssertEqual((storage?.uiContext as! NSManagedObjectContext).parent, storage?.rootContext)
        XCTAssertEqual((storage?.uiContext as! NSManagedObjectContext).concurrencyType, NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    }
    
    func testStoreRemoval() {
        _ = try? storage?.wipeStore()
        let path = store!.location().path
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: path))
    }

    func testSave() {
        _ = try? storage?.perform(true, unitOfWork: { (context, save) -> Void in
            let _: Car = try! context.create()
            save()
        })
        let request: Request<Car> = Request()
        let carsCount: Int? = try! storage?.uiContext.fetch(request).count
        
        XCTAssertEqual(carsCount, 1)
    }
}
