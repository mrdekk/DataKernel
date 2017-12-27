//
//  FileUtilsTests.swift
//  DataKernel
//
//  Created by Denis Malykh on 02/05/16.
//  Copyright © 2016 mrdekk. All rights reserved.
//

import XCTest
@testable import DataKernel

class FileUtilsTests: XCTestCase {
    
    func testProperDocumentsDirectory() {
        let path = FileUtils.documents()
        
        XCTAssertEqual(path, NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], "should return the proper documents directory")
    }

//    NOTE: disabled because for using app groups there should be a capability with entitlements, but for public project it is impossible
//    NOTE: you can test such thing in your own project
//    func testProperPathInAppGroup() {
//        guard let url = FileUtils.documents(in: "group") else {
//            XCTAssert(false, "url should be set")
//            return
//        }
//
//        guard let expected = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group") else {
//            XCTAssert(false, "expected should be set")
//            return
//        }
//
//        XCTAssertEqual(url, expected, "should return the proper documents directory in app group 'group'")
//    }
}
