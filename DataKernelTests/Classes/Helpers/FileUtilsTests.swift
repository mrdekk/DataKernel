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
        
        XCTAssertEqual(path, NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0], "should return the proper documents directory")
    }
    
}
