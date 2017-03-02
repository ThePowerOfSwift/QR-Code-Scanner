//
//  QRCodeReaderTests.swift
//  QRCodeReaderTests
//
//  Created by Ali on 3/1/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import XCTest
@testable import QRCodeReader

class QRCodeReaderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func test1() {
        let viewController = ViewController()
         viewController.infoLabel = UILabel()
        
        viewController.found(info: "https://vk.com")
        XCTAssertFalse(viewController.infoLabel.isHidden)
        XCTAssertTrue(viewController.infoLabel.text == "https://vk.com")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
