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

import CRDT
import CRDTRegisters

extension Int: PartialOrderable {

}

public final class LWWRegisterTests: XCTestCase {
    func testExample() throws {
        var r = LWWRegister<String, Int>(value: "a", timestamp: 2)
        try r.assign(value: "b", timestamp: 1)
        XCTAssertEqual("a", r.value)

        XCTAssertThrowsError(try r.assign(value: "b", timestamp: 2), "") { error in
            guard let crdtError = error as? LWWRegister<String, Int>.Error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
            switch crdtError {
            case .uncomparableTimestamps:
                XCTFail("Unexpected error: \(error)")
            case .conflictingValuesForSameTimestamp:
                break
            }
        }
        XCTAssertEqual("a", r.value)

        try r.assign(value: "a", timestamp: 2)
        XCTAssertEqual("a", r.value)
    }

    func testUpdateWithOldTimestamp() throws {
        var r = LWWRegister<String, Int>(value: "a", timestamp: 2)
        try r.assign(value: "b", timestamp: 1)
        XCTAssertEqual("a", r.value)
    }

    func testUpdateSameValueAndSameTimestamp() throws {
        var r = LWWRegister<String, Int>(value: "a", timestamp: 2)
        try r.assign(value: "a", timestamp: 2)
        XCTAssertEqual("a", r.value)
    }

    func testUpdateThrowsErrorIfDifferentValueAndSameTimestamp() throws {
        var r = LWWRegister<String, Int>(value: "a", timestamp: 2)
        XCTAssertThrowsError(try r.assign(value: "b", timestamp: 2), "") { error in
            guard let crdtError = error as? LWWRegister<String, Int>.Error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
            switch crdtError {
            case .uncomparableTimestamps:
                XCTFail("Unexpected error: \(error)")
            case .conflictingValuesForSameTimestamp:
                break
            }
        }
        XCTAssertEqual("a", r.value)
    }

    func testUpdateDifferentValueAndDifferentTimestamp() throws {
        var r = LWWRegister<String, Int>(value: "a", timestamp: 2)
        try r.assign(value: "b", timestamp: 3)
        XCTAssertEqual("b", r.value)

        try r.assign(value: "b", timestamp: 4)
        XCTAssertEqual("b", r.value)

        try r.assign(value: "c", timestamp: 5)
        XCTAssertEqual("c", r.value)
    }

    func testMergeThrowsErrorIfNotEqualValueForSameTimestamp() throws {
        var a = LWWRegister<String, Int>(value: "a", timestamp: 2)
        let b = LWWRegister<String, Int>(value: "b", timestamp: 2)

        XCTAssertThrowsError(try a.merge(b), "") { error in
            guard let crdtError = error as? LWWRegister<String, Int>.Error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
            switch crdtError {
            case .uncomparableTimestamps:
                XCTFail("Unexpected error: \(error)")
            case .conflictingValuesForSameTimestamp:
                break
            }
        }
    }
}
