//  Copyright 2019 Bryant Luk
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import XCTest

import struct Foundation.UUID

import CRDTRegisters

public final class MVRegisterTests: XCTestCase {
    func testExample() throws {
        var r1 = MVRegister<String, UUID, Int>()
        var r2 = r1

        let actorA = UUID()
        try r1.put(value: "bob", for: actorA)
        var r1ReadContext = try r1.makeReadContext()
        XCTAssertEqual(r1ReadContext.values, ["bob"])

        var r3 = r1
        var r3ReadContext = try r3.makeReadContext()
        XCTAssertEqual(r3ReadContext.values, ["bob"])

        let actorB = UUID()
        var r2ReadContext = try r2.makeReadContext()
        XCTAssertEqual(r2ReadContext.values, [])

        let r2PutAliceOperation = r2ReadContext.makePutOperation(value: "alice", for: actorB)
        try r2.apply(r2PutAliceOperation)
        // The original read context is still empty
        XCTAssertEqual(r2ReadContext.values, [])

        // Cannot reuse a read context to make more than one put operation for an actor
        let r2PutJaneOperationReuseContext = r2ReadContext.makePutOperation(value: "jane", for: actorB)
        XCTAssertThrowsError(try r2.apply(r2PutJaneOperationReuseContext), "") { error in
            guard let crdtError = error as? MVRegister<String, UUID, Int>.Error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
            switch crdtError {
            case .conflictingValuesForSameVClock:
                break
            }
        }

        // Make a new read context which has the values
        r2ReadContext = try r2.makeReadContext()
        XCTAssertEqual(r2ReadContext.values, ["alice"])

        // Can apply an operation to another register
        try r1.apply(r2PutAliceOperation)
        r1ReadContext = try r1.makeReadContext()
        XCTAssertEqual(Set(r1ReadContext.values), ["bob", "alice"])
        r2ReadContext = try r2.makeReadContext()
        XCTAssertEqual(r2ReadContext.values, ["alice"])

        // Can merge two registers
        try r3.merge(r2)
        r3ReadContext = try r3.makeReadContext()
        XCTAssertEqual(Set(r3ReadContext.values), ["bob", "alice"])

        // Recouncile the different values and assign a new value
        try r1.put(value: "lisa", for: actorA)
        r1ReadContext = try r1.makeReadContext()
        XCTAssertEqual(Set(r1ReadContext.values), ["lisa"])

        try r3.merge(r1)
        r3ReadContext = try r3.makeReadContext()
        XCTAssertEqual(Set(r3ReadContext.values), ["lisa"])
    }
}
