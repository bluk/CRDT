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

public final class ActorDateTimestampTests: XCTestCase {
     func testExample() throws {
        let actorA = UUID()
        var lwwr1 = LWWRegister<String, ActorDateTimestamp>(value: "hello", actor: actorA)
        XCTAssertEqual(lwwr1.value, "hello")
        let originalVClock = lwwr1.timestamp

        try lwwr1.assign(value: "hello world", for: actorA)
        XCTAssertEqual(lwwr1.value, "hello world")

        try lwwr1.assign(value: "hi!", timestamp: originalVClock)
        XCTAssertEqual(lwwr1.value, "hello world")

        let actorB = UUID()
        let lwwr2 = LWWRegister<String, ActorDateTimestamp>(value: "other", actor: actorB)
        XCTAssertEqual(lwwr2.value, "other")

        try lwwr1.merge(lwwr2)
        XCTAssertEqual(lwwr1.value, "other")
     }
}
