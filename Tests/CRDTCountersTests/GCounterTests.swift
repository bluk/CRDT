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

import CRDTCounters

public final class GCounterTests: XCTestCase {
    func testExample() throws {
        // First system increments a clock
        let actorA = UUID()
        var a = GCounter<UUID>()

        a.incrementCounter(for: actorA)
        XCTAssertEqual(a.value, 1)

        // Serialize the state of the counter.
        let jsonEncoder = JSONEncoder()
        let encodedData = try jsonEncoder.encode(a)

        // Second system increments a clock.
        let actorB = UUID()
        var b = GCounter<UUID>()

        b.incrementCounter(for: actorB)
        XCTAssertEqual(a.value, 1)
        XCTAssertEqual(b.value, 1)

        // Third system receives the serialized counter and deserializes it.
        let jsonDecoder = JSONDecoder()
        var c = try jsonDecoder.decode(GCounter<UUID>.self, from: encodedData)

        // Third system receives the second system's state and merges it.
        try c.merge(b)
        XCTAssertEqual(a.value, 1)
        XCTAssertEqual(b.value, 1)
        XCTAssertEqual(c.value, 2)

        // First system continues incrementing.
        a.incrementCounter(for: actorA)
        a.incrementCounter(for: actorA)

        // Third system receives the first system's state and merges it.
        try c.merge(a)
        XCTAssertEqual(a.value, 3)
        XCTAssertEqual(b.value, 1)
        XCTAssertEqual(c.value, 4)

        // Merge all the states together.
        try a.merge(c)
        try a.merge(b)
        try b.merge(a)
        try b.merge(c)
        try c.merge(c)
        XCTAssertEqual(a.value, 4)
        XCTAssertEqual(b.value, 4)
        XCTAssertEqual(c.value, 4)
    }

    func testIncrementCounter() throws {
        let actorA = "A"
        var a = GCounter<String>()
        let actorB = "B"
        var b = GCounter<String>()

        let incrementAOperation1 = a.incrementCounter(for: actorA)
        let incrementBOperation1 = b.incrementCounter(for: actorB)

        XCTAssertEqual(a.value, b.value)
        XCTAssertNotEqual(a, b)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)

        let oldAValue = a.value
        a.apply(incrementAOperation1)
        XCTAssertEqual(a.value, oldAValue)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)

        let incrementAOperation2 = a.incrementCounter(for: actorA)
        XCTAssertTrue(a.value > b.value)
        XCTAssertEqual(a.value, b.value + 1)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)

        let newAValue = a.value
        a.apply(incrementAOperation1)
        XCTAssertEqual(a.value, newAValue)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)
        XCTAssertFalse(a <= b)
        XCTAssertFalse(b <= a)

        a.apply(incrementBOperation1)
        XCTAssertTrue(a.value > b.value)
        XCTAssertEqual(a.value, b.value + 2)
        XCTAssertFalse(a < b)
        XCTAssertTrue(b < a)
        XCTAssertFalse(a <= b)
        XCTAssertTrue(b <= a)

        b.apply(incrementAOperation2)
        XCTAssertEqual(a.value, b.value)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)
        XCTAssertTrue(a <= b)
        XCTAssertTrue(b <= a)
    }

    func testMakeIncrementCounterOperation() throws {
        let actorA = "A"
        var a = GCounter<String>()
        let actorB = "B"
        var b = GCounter<String>()

        let incrementAOperation1 = a.makeIncrementCounterOperation(for: actorA)
        a.apply(incrementAOperation1)
        let incrementBOperation1 = b.makeIncrementCounterOperation(for: actorB)
        b.apply(incrementBOperation1)

        XCTAssertEqual(a.value, b.value)
        XCTAssertNotEqual(a, b)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)

        let oldAValue = a.value
        a.apply(incrementAOperation1)
        XCTAssertEqual(a.value, oldAValue)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)

        let incrementAOperation2 = a.makeIncrementCounterOperation(for: actorA)
        a.apply(incrementAOperation2)
        XCTAssertTrue(a.value > b.value)
        XCTAssertEqual(a.value, b.value + 1)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)

        let newAValue = a.value
        a.apply(incrementAOperation1)
        XCTAssertEqual(a.value, newAValue)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)
        XCTAssertFalse(a <= b)
        XCTAssertFalse(b <= a)

        a.apply(incrementBOperation1)
        XCTAssertTrue(a.value > b.value)
        XCTAssertEqual(a.value, b.value + 2)
        XCTAssertFalse(a < b)
        XCTAssertTrue(b < a)
        XCTAssertFalse(a <= b)
        XCTAssertTrue(b <= a)

        b.apply(incrementAOperation2)
        XCTAssertEqual(a.value, b.value)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)
        XCTAssertTrue(a <= b)
        XCTAssertTrue(b <= a)
    }
}
