//
//  CoreDataContextTests.swift
//  DataKernel
//
//  Created by Denis Malykh on 03/05/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import XCTest
import CoreData
@testable import DataKernel

class CoreDataContextTests: XCTestCase {
    
    var store: StoreRef?
    var model: ModelRef?
    var storage: CoreDataLocalStorage?
    
    override func setUp() {
        super.setUp()
        
        store = .Named("test2")
        let bundle = NSBundle(forClass: self.classForCoder)
        model = .Merged([bundle])
        self.storage = try! CoreDataLocalStorage(store: store!, model: model!, migration: true)
    }
    
    override func tearDown() {
        _ = try? storage?.wipeStore()
        
        super.tearDown()
    }
    
    func testCreateAndFetch() {
        _ = try? storage?.perform(true, unitOfWork: { (context, save) -> Void in
            let car: Car = try! context.create()
            car.mark = "Honda"
            car.model = "CRZ"
            save()
        })
        let request: Request<Car> = Request()
        let results = try! storage?.uiContext.fetch(request)
        let firstCar = results?.first

        XCTAssertEqual(results?.count, 1)
        XCTAssertNotNil(firstCar)
        XCTAssertEqual(firstCar?.mark, "Honda")
        XCTAssertEqual(firstCar?.model, "CRZ")
    }
    
    func testCreateAndCount() {
        _ = try? storage?.perform(true, unitOfWork: { (context, save) -> Void in
            let car: Car = try! context.create()
            car.mark = "Honda"
            car.model = "CRZ"
            
            let car2: Car = try! context.create()
            car2.mark = "Honda"
            car2.model = "Insight"
            
            let car3: Car = try! context.create()
            car3.mark = "Honda"
            car3.model = "Integra"
            
            save()
        })
        
        let request: Request<Car> = Request().filter("mark", equalTo: "Honda")
        let count = try! storage?.uiContext.count(request)
        
        XCTAssertEqual(count, 3)
    }
    
    func testAcquire() {
        let request: Request<Car> = Request()
        
        let results = try! storage?.uiContext.fetch(request)
        
        XCTAssertEqual(results?.count, 0)

        _ = try? storage?.perform(true, unitOfWork: { (context, save) -> Void in
            let car: Car = try! context.acquire("CRZ")
            car.mark = "Honda"
            car.model = "CRZ"
            save()
        })
        
        let results2 = try! storage?.uiContext.fetch(request)
        let firstCar = results2?.first
        
        XCTAssertEqual(results2?.count, 1)
        XCTAssertNotNil(firstCar)
        XCTAssertEqual(firstCar?.mark, "Honda")
        XCTAssertEqual(firstCar?.model, "CRZ")
        
        _ = try? storage?.perform(true, unitOfWork: { (context, save) -> Void in
            let car2: Car = try! context.acquire("CRZ")
            car2.mark = "Honda"
            save()
        })
        
        let results3 = try! storage?.uiContext.fetch(request)
        let firstCar2 = results3?.first
        
        XCTAssertEqual(results3?.count, 1)
        XCTAssertNotNil(firstCar2)
        XCTAssertEqual(firstCar2?.mark, "Honda")
        XCTAssertEqual(firstCar2?.model, "CRZ")
    }
    
    func testRemoveOne() {
        _ = try? storage?.perform(true, unitOfWork: { (context, save) -> Void in
            let car: Car = try! context.create()
            car.mark = "Honda"
            car.model = "CRZ"
            
            let car2: Car = try! context.create()
            car2.mark = "Honda"
            car2.model = "Insight"
            
            save()
        })
        
        let request: Request<Car> = Request().filter("model", equalTo: "CRZ")
        let results = try! storage?.uiContext.fetch(request)
        let firstCar = results?.first
        
        XCTAssertEqual(results?.count, 1)
        XCTAssertNotNil(firstCar)
        XCTAssertEqual(firstCar?.mark, "Honda")
        XCTAssertEqual(firstCar?.model, "CRZ")
        
        _ = try? storage?.perform(true, unitOfWork: { (context, save) -> Void in
            let cars = try! context.fetch(request)
            if let car = cars.first {
                try! context.remove(car)
            } else {
                XCTAssertTrue(false)
            }
            save()
        })
        
        let results2 = try! storage?.uiContext.fetch(request)
        
        XCTAssertEqual(results2?.count, 0)
    }

    func testRemoveMany() {
        _ = try? storage?.perform(true, unitOfWork: { (context, save) -> Void in
            let car: Car = try! context.create()
            car.mark = "Honda"
            car.model = "CRZ"
            
            let car2: Car = try! context.create()
            car2.mark = "Honda"
            car2.model = "Insight"
            
            save()
        })
        
        let request: Request<Car> = Request().filter("mark", equalTo: "Honda")
        let results = try! storage?.uiContext.fetch(request)
        
        XCTAssertEqual(results?.count, 2)
        
        _ = try? storage?.perform(true, unitOfWork: { (context, save) -> Void in
            let cars = try! context.fetch(request)
            try! context.remove(cars)
            save()
        })
        
        let results2 = try! storage?.uiContext.fetch(request)
        
        XCTAssertEqual(results2?.count, 0)
    }

    func testRemoveConditional() {
        _ = try? storage?.perform(true, unitOfWork: { (context, save) -> Void in
            let car: Car = try! context.create()
            car.mark = "Honda"
            car.model = "CRZ"
            
            let car2: Car = try! context.create()
            car2.mark = "Honda"
            car2.model = "Insight"
            
            save()
        })
        
        let request: Request<Car> = Request().filter("mark", equalTo: "Honda")
        let results = try! storage?.uiContext.fetch(request)
        
        XCTAssertEqual(results?.count, 2)
        
        _ = try? storage?.perform(true, unitOfWork: { (context, save) -> Void in
            try! context.remove(request)
            save()
        })
        
        let results2 = try! storage?.uiContext.fetch(request)
        
        XCTAssertEqual(results2?.count, 0)
    }
    
    func testWipe() {
        _ = try? storage?.perform(true, unitOfWork: { (context, save) -> Void in
            let car: Car = try! context.create()
            car.mark = "Honda"
            car.model = "CRZ"
            
            let car2: Car = try! context.create()
            car2.mark = "Honda"
            car2.model = "Insight"
            
            save()
        })
        
        let request: Request<Car> = Request().filter("mark", equalTo: "Honda")
        let results = try! storage?.uiContext.fetch(request)
        
        XCTAssertEqual(results?.count, 2)
        
        _ = try? storage?.perform(true, unitOfWork: { (context, save) -> Void in
            try! context.wipe(Car.self)
            save()
        })
        
        let results2 = try! storage?.uiContext.fetch(request)
        
        XCTAssertEqual(results2?.count, 0)
        
    }
}
