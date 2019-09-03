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

public final class ActorLogicalClockTimestampTests: XCTestCase {
     func testExample() throws {
        let actorA = UUID()
        var lwwr1 = LWWRegister<String, ActorLogicalClockTimestamp>(value: "hello", actor: actorA)
        XCTAssertEqual(lwwr1.value, "hello")

        var lwwr2 = lwwr1
        XCTAssertEqual(lwwr2.value, "hello")

        try lwwr1.assign(value: "hello world", for: actorA)
        XCTAssertEqual(lwwr1.value, "hello world")
        XCTAssertEqual(lwwr2.value, "hello")

        try lwwr2.merge(lwwr1)
        XCTAssertEqual(lwwr1.value, "hello world")
        XCTAssertEqual(lwwr2.value, "hello world")

        try lwwr1.assign(value: "goodbye", for: actorA)

        let actorB = UUID()
        try lwwr2.assign(value: "cya", for: actorB)
        XCTAssertEqual(lwwr1.value, "goodbye")
        XCTAssertEqual(lwwr2.value, "cya")

        // Values have split history for actorA and actorB. Would need to add
        // custom logic to resolve merge conflict (e.g. pick a value going forward).

        XCTAssertThrowsError(try lwwr1.merge(lwwr2), "") { error in
            guard let crdtError = error as? LWWRegister<String, ActorLogicalClockTimestamp>.Error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
            switch crdtError {
            case .conflictingValuesForSameTimestamp:
                XCTFail("Unexpected error: \(error)")
            case .uncomparableTimestamps:
                break
            }
        }
        XCTAssertEqual(lwwr1.value, "goodbye")
        XCTAssertEqual(lwwr2.value, "cya")

        XCTAssertThrowsError(try lwwr2.merge(lwwr1), "") { error in
            guard let crdtError = error as? LWWRegister<String, ActorLogicalClockTimestamp>.Error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
            switch crdtError {
            case .conflictingValuesForSameTimestamp:
                XCTFail("Unexpected error: \(error)")
            case .uncomparableTimestamps:
                break
            }
        }
        XCTAssertEqual(lwwr1.value, "goodbye")
        XCTAssertEqual(lwwr2.value, "cya")
     }
}
