//
//  RequestTests.swift
//  DataKernel
//
//  Created by Denis Malykh on 02/05/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import XCTest
@testable import DataKernel

class RequestTests: XCTestCase {
    
    func testRequestWithPredicate() {
        let predicate = NSPredicate(format: "model == CRZ")
        let request: DataRequest<Car> = DataRequest(predicate: predicate)
        
        XCTAssertEqual(request.predicate, predicate)
    }
    
    func testRequestWithKeyAndValue() {
        let predicate = NSPredicate(format: "model == %@", "CRZ")
        let request: DataRequest<Car> = DataRequest().filter("model", equalTo: "CRZ")
        
        XCTAssertEqual(request.predicate, predicate)
    }
    
    func testRequestWithKeyAndValues() {
        let predicate = NSPredicate(format: "model IN %@", ["CRZ", "Insight", "Integra"])
        let request: DataRequest<Car> = DataRequest().filter("model", oneOf: ["CRZ", "Insight", "Integra"])
        
        XCTAssertEqual(request.predicate, predicate)
    }
    
    func testRequestSortWithKeyAndAscending() {
        let descriptor = NSSortDescriptor(key: "model", ascending: true)
        let request: DataRequest<Car> = DataRequest().sort("model", ascending: true)
        
        XCTAssertEqual(descriptor.key, request.sort?.key)
        XCTAssertEqual(descriptor.ascending, request.sort?.ascending)
    }
    
    func testRequestSortWithKeyAndAscendingAndComparator() {
        let descriptor = NSSortDescriptor(key: "model", ascending: true, comparator: { _ in return NSComparisonResult.OrderedSame })
        let request: DataRequest<Car> = DataRequest().sort("model", ascending: true, comparator: { _ in return NSComparisonResult.OrderedSame })
        
        XCTAssertEqual(descriptor.key, request.sort?.key)
        XCTAssertEqual(descriptor.ascending, request.sort?.ascending)
        // TODO: may be compare result of comparator on same input values and vice versa
    }
    
    func testRequestSortWithKeyAndAscendingAndSelector() {
        let descriptor = NSSortDescriptor(key: "model", ascending: true, selector: Selector("selector"))
        let request: DataRequest<Car> = DataRequest().sort("model", ascending: true, selector: Selector("selector"))
        
        XCTAssertEqual(descriptor.key, request.sort?.key)
        XCTAssertEqual(descriptor.ascending, request.sort?.ascending)
        XCTAssertEqual(descriptor.selector, request.sort?.selector)
    }
    
}
