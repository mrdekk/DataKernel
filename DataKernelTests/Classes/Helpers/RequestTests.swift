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
        let request: Request<Car> = Request(predicate: predicate)
        
        XCTAssertEqual(request.predicate, predicate)
    }
    
    func testRequestWithKeyAndValue() {
        let predicate = NSPredicate(format: "model == %@", "CRZ")
        let request: Request<Car> = Request().filtered("model", equalTo: "CRZ")
        
        XCTAssertEqual(request.predicate, predicate)
    }
    
    func testRequestWithKeyAndValues() {
        let predicate = NSPredicate(format: "model IN %@", ["CRZ", "Insight", "Integra"])
        let request: Request<Car> = Request().filtered("model", oneOf: ["CRZ", "Insight", "Integra"])
        
        XCTAssertEqual(request.predicate, predicate)
    }
    
    func testRequestSortWithKeyAndAscending() {
        let descriptor = NSSortDescriptor(key: "model", ascending: true)
        let request: Request<Car> = Request().sorted("model", ascending: true)
        
        XCTAssertEqual(descriptor.key, request.sort?.key)
        XCTAssertEqual(descriptor.ascending, request.sort?.ascending)
    }
    
    func testRequestSortWithKeyAndAscendingAndComparator() {
        let descriptor = NSSortDescriptor(key: "model", ascending: true, comparator: { _,_  in return ComparisonResult.orderedSame })
        let request: Request<Car> = Request().sorted("model", ascending: true, comparator: { _,_ in return ComparisonResult.orderedSame })
        
        XCTAssertEqual(descriptor.key, request.sort?.key)
        XCTAssertEqual(descriptor.ascending, request.sort?.ascending)
        // TODO: may be compare result of comparator on same input values and vice versa
    }
    
    func testRequestSortWithKeyAndAscendingAndSelector() {
        let descriptor = NSSortDescriptor(key: "model", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let request: Request<Car> = Request().sorted("model", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        
        XCTAssertEqual(descriptor.key, request.sort?.key)
        XCTAssertEqual(descriptor.ascending, request.sort?.ascending)
        XCTAssertEqual(descriptor.selector, request.sort?.selector)
    }
    
}
