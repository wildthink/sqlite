//
//  FieldDecoderTests.swift
//  
//
//  Created by Jason Jobe on 1/4/23.
//

import XCTest
@testable import SQLite

final class FieldDecoderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFieldDecoder() throws {
        let decoder = FieldsDecoder()
        _ = try User(from: decoder)
        print(decoder.keys.map { $0.snakeCased })
        print(decoder.schema)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

struct User: Codable {
    var name: String
    var createdAt: Date
    var updatedAt: Date?
    var githubId: Int
    var keys: [String]
    var pt: CGPoint
}

//extension User {
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.name = try container.decode(String.self, forKey: .name)
//        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
//        // ...
//    }
//}
