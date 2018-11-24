//
//  UberTests.swift
//  UberTests
//
//  Created by Murali on 24/11/18.
//  Copyright © 2018 MuraliNallusamy. All rights reserved.
//

import XCTest
@testable import Uber

class UberTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func photoExtractor() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        PhotoManager().search("Photo") { (photo, error) in
            XCTAssertNotNil(photo.count, "Failed to load")
        }
    }
    
    func photoPagination() {
        PhotoManager().nextPage(currentRow: IndexPath(row: 20, section: 0)) { (photo, error) in
            XCTAssertNotNil(photo.count, "Failed to load")
        }
    }
}
