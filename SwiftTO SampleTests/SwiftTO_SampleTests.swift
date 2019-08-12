//
//  SwiftTO_SampleTests.swift
//  SwiftTO SampleTests
//
//  Created by Marwan Alani on 2019-08-11.
//  Copyright © 2019 Marwan Alani. All rights reserved.
//

import XCTest
@testable import SwiftTO_Sample

class SwiftTO_SampleTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUserGenerationFromApiUser() {
        let apiUser1 = ApiUser(name: ApiName(first: "John", last: "doe"), phone: "1234567890")
        let apiUser2 = ApiUser(name: ApiName(first: "jane", last: ""), phone: "1234567890123")
        let apiUser3 = ApiUser(name: ApiName(first: "Jimmy 🎸", last: "Hendrix"), phone: "N/A")
        
        let user1 = User(fromNetworkUser: apiUser1)
        let user2 = User(fromNetworkUser: apiUser2)
        let user3 = User(fromNetworkUser: apiUser3)
        
        XCTAssert(user1.name == "John Doe")
        XCTAssert(user1.phone == "1234567890")
        
        XCTAssert(user2.name == "Jane ")
        XCTAssert(user2.phone == "1234567890123")
        
        XCTAssert(user3.name == "Jimmy 🎸 Hendrix")
        XCTAssert(user3.phone == "N/A")
    }
}
