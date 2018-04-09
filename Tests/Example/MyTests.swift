//
//  Tests.swift
//  SwiftTestLinux
//
//  Created by iainsmith on 09/04/2018.
//

import XCTest

class MyTests: XCTestCase {
    func testHello() {
        XCTAssertTrue(true)
    }

    static var allTests = [
        ("testHello", MyTests.testHello)
    ]
}
