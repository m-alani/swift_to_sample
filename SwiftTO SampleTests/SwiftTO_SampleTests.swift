//
//  SwiftTO_SampleTests.swift
//  SwiftTO SampleTests
//
//  Created by Marwan Alani on 2019-08-11.
//  Copyright © 2019 Marwan Alani. All rights reserved.
//

import XCTest
@testable import SwiftTO_Sample


// MARK: Tests

class SwiftTO_SampleTests: XCTestCase {

    func testUserGenerationFromApiUser() {
        let apiUser1 = ApiUser(name: ApiName(first: "John", last: "doe"), phone: "1234567890")
        let apiUser2 = ApiUser(name: ApiName(first: "jane", last: ""), phone: "1234567890123")
        let apiUser3 = ApiUser(name: ApiName(first: "Jimmy 🎸", last: "Hendrix"), phone: "N/A")
        
        let user1 = createUser(from: apiUser1)
        let user2 = createUser(from: apiUser2)
        let user3 = createUser(from: apiUser3)
        
        XCTAssert(user1.name == "John Doe")
        XCTAssert(user1.phone == "1234567890")
        
        XCTAssert(user2.name == "Jane ")
        XCTAssert(user2.phone == "1234567890123")
        
        XCTAssert(user3.name == "Jimmy 🎸 Hendrix")
        XCTAssert(user3.phone == "N/A")
    }
    
    func testFetchUsersValidUrlSuccess() {
        let (mockSession, mockUsers, mockResponseData, _) = mocks()
        
        mockSession.data = mockResponseData
        mockSession.error = nil
        
        fetchUsers(from: "https://google.ca", using: mockSession) { (users) in
            XCTAssert(users == mockUsers)
        }
    }
    
    func testFetchUsersValidUrlFailure() {
        let (mockSession, _ , _ , mockError) = mocks()
        
        mockSession.error = mockError
        
        fetchUsers(from: "https://google.ca", using: mockSession) { (users) in
            XCTAssert(users.count == 0)
        }
    }
}

// MARK: Mock Classes

class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    
    init(withClosure closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }
}

class MockURLSession: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    var data: Data?
    var error: Error?
    
    override func dataTask(with url: URL, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        
        return MockURLSessionDataTask {
            completionHandler(data, nil, error)
        }
    }
}

class MockError: Error { }

// MARK: Helper Functions

func mocks() -> (MockURLSession, [User], Data, Error) {
    let mockSession = MockURLSession()
    let mockUsers = [User(name: "John Doe", phone: "123-456-7890"),
                     User(name: "Jane Doe", phone: "321-654-0987")]
    let mockApiUsers = [ApiUser(name: ApiName(first: "John", last: "Doe"), phone: "123-456-7890"),
                        ApiUser(name: ApiName(first: "Jane", last: "Doe"), phone: "321-654-0987")]
    let mockResponse = ApiResponse(results: mockApiUsers)
    let mockResponseData = try! JSONEncoder().encode(mockResponse)
    let mockError = MockError()
    
    return (mockSession, mockUsers, mockResponseData, mockError)
}
