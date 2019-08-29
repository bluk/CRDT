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

public final class PNCounterTests: XCTestCase {
    func testExample() throws {
        // First system increments a clock
        let actorA = UUID()
        var a = PNCounter<UUID>()

        a.incrementCounter(for: actorA)
        XCTAssertEqual(a.value, 1)

        // Serialize the state of the counter.
        let jsonEncoder = JSONEncoder()
        let encodedData = try jsonEncoder.encode(a)

        // Second system increments a clock.
        let actorB = UUID()
        var b = PNCounter<UUID>()

        b.incrementCounter(for: actorB)
        b.incrementCounter(for: actorB)
        XCTAssertEqual(a.value, 1)
        XCTAssertEqual(b.value, 2)

        // Third system receives the serialized counter and deserializes it.
        let jsonDecoder = JSONDecoder()
        var c = try jsonDecoder.decode(PNCounter<UUID>.self, from: encodedData)

        // Third system receives the second system's state and merges it.
        try c.merge(b)
        XCTAssertEqual(a.value, 1)
        XCTAssertEqual(b.value, 2)
        XCTAssertEqual(c.value, 3)

        // First system continues incrementing.
        a.incrementCounter(for: actorA)
        a.incrementCounter(for: actorA)
        XCTAssertEqual(a.value, 3)

        // Second system decrements a value.
        b.decrementCounter(for: actorB)
        XCTAssertEqual(b.value, 1)

        // Third system receives the first system's state and merges it.
        // It has not received the updated second system's state.
        try c.merge(a)
        XCTAssertEqual(a.value, 3)
        XCTAssertEqual(b.value, 1)
        XCTAssertEqual(c.value, 5)

        // Third system receives the second system's state and merges it.
        try c.merge(b)
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
        var a = PNCounter<String>()
        let actorB = "B"
        var b = PNCounter<String>()

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
        var a = PNCounter<String>()
        let actorB = "B"
        var b = PNCounter<String>()

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

    func testDecrementCounter() throws {
        let actorA = "A"
        var a = PNCounter<String>()
        let actorB = "B"
        var b = PNCounter<String>()

        let decrementAOperation1 = a.decrementCounter(for: actorA)
        let decrementBOperation1 = b.decrementCounter(for: actorB)

        XCTAssertEqual(a.value, b.value)
        XCTAssertNotEqual(a, b)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)

        let oldAValue = a.value
        a.apply(decrementAOperation1)
        XCTAssertEqual(a.value, oldAValue)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)

        let decrementAOperation2 = a.decrementCounter(for: actorA)
        XCTAssertTrue(a.value < b.value)
        XCTAssertEqual(a.value, b.value - 1)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)

        let newAValue = a.value
        a.apply(decrementAOperation1)
        XCTAssertEqual(a.value, newAValue)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)
        XCTAssertFalse(a <= b)
        XCTAssertFalse(b <= a)

        a.apply(decrementBOperation1)
        XCTAssertTrue(a.value < b.value)
        XCTAssertEqual(a.value, b.value - 2)
        XCTAssertFalse(a < b)
        XCTAssertTrue(b < a)
        XCTAssertFalse(a <= b)
        XCTAssertTrue(b <= a)

        b.apply(decrementAOperation2)
        XCTAssertEqual(a.value, b.value)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)
        XCTAssertTrue(a <= b)
        XCTAssertTrue(b <= a)
    }

    func testMakeDecrementCounterOperation() throws {
        let actorA = "A"
        var a = PNCounter<String>()
        let actorB = "B"
        var b = PNCounter<String>()

        let decrementAOperation1 = a.makeDecrementCounterOperation(for: actorA)
        a.apply(decrementAOperation1)
        let decrementBOperation1 = b.makeDecrementCounterOperation(for: actorB)
        b.apply(decrementBOperation1)

        XCTAssertEqual(a.value, b.value)
        XCTAssertNotEqual(a, b)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)

        let oldAValue = a.value
        a.apply(decrementAOperation1)
        XCTAssertEqual(a.value, oldAValue)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)

        let decrementAOperation2 = a.makeDecrementCounterOperation(for: actorA)
        a.apply(decrementAOperation2)
        XCTAssertTrue(a.value < b.value)
        XCTAssertEqual(a.value, b.value - 1)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)

        let newAValue = a.value
        a.apply(decrementAOperation1)
        XCTAssertEqual(a.value, newAValue)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)
        XCTAssertFalse(a <= b)
        XCTAssertFalse(b <= a)

        a.apply(decrementBOperation1)
        XCTAssertTrue(a.value < b.value)
        XCTAssertEqual(a.value, b.value - 2)
        XCTAssertFalse(a < b)
        XCTAssertTrue(b < a)
        XCTAssertFalse(a <= b)
        XCTAssertTrue(b <= a)

        b.apply(decrementAOperation2)
        XCTAssertEqual(a.value, b.value)
        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)
        XCTAssertTrue(a <= b)
        XCTAssertTrue(b <= a)
    }
}
