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

// swiftlint:disable file_length

public final class VClockTests: XCTestCase {
    let processA = "ProcessA"
    let processB = "ProcessB"
    let processC = "ProcessC"
    let zeroValue = 0

    func testIncrementClock() {
        var vClock1 = VClock<String, Int>()
        var vClock2 = VClock<String, Int>()
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertTrue(vClock1.allClocksAtZeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)
        XCTAssertTrue(vClock2.allClocksAtZeroValue)

        let incrementProcessAOperation1 = vClock1.incrementClock(for: processA)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertFalse(vClock1.allClocksAtZeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)
        XCTAssertTrue(vClock2.allClocksAtZeroValue)

        vClock2.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertFalse(vClock1.allClocksAtZeroValue)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertFalse(vClock2.allClocksAtZeroValue)
    }

    func testMakeIncrementClockOperationAndApply() {
        var vClock1 = VClock<String, Int>()
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertTrue(vClock1.allClocksAtZeroValue)

        let incrementProcessAOperation1 = vClock1.makeIncrementClockOperation(for: processA)
        XCTAssertEqual(vClock1[processA], zeroValue)

        vClock1.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)

        // Apply same operation repeatedly
        vClock1.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)

        let incrementProcessAOperation2 = vClock1.makeIncrementClockOperation(for: processA)
        XCTAssertEqual(vClock1[processA], 1)

        // Apply original operation after making new operation
        vClock1.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)

        vClock1.apply(incrementProcessAOperation2)
        XCTAssertEqual(vClock1[processA], 2)

        vClock1.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 2)
    }

    func testZeroValuesNotStored() {
        var vClock1 = VClock<String, Int>()
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertTrue(vClock1.allClocksAtZeroValue)

        let processAClock0 = VClock<String, Int>.ActorClock(actor: processA, clock: 0)
        vClock1.apply(processAClock0)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertTrue(vClock1.allClocksAtZeroValue)
    }

    func testLessThan() {
        var vClock1 = VClock<String, Int>()
        var vClock2 = VClock<String, Int>()

        XCTAssertFalse(vClock1 < vClock2)
        XCTAssertFalse(vClock2 < vClock1)

        let incrementProcessAOperation1 = vClock1.makeIncrementClockOperation(for: processA)
        vClock1.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], zeroValue)
        XCTAssertFalse(vClock1 < vClock2)
        XCTAssertTrue(vClock2 < vClock1)

        vClock2.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertFalse(vClock1 < vClock2)
        XCTAssertFalse(vClock2 < vClock1)

        vClock1.incrementClock(for: processB)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], 0)
        XCTAssertFalse(vClock1 < vClock2)
        XCTAssertTrue(vClock2 < vClock1)
    }

    func testLessThanEqual() {
        var vClock1 = VClock<String, Int>()
        var vClock2 = VClock<String, Int>()

        XCTAssertTrue(vClock1 <= vClock2)
        XCTAssertTrue(vClock2 <= vClock1)

        let incrementProcessAOperation1 = vClock1.makeIncrementClockOperation(for: processA)
        vClock1.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], zeroValue)
        XCTAssertFalse(vClock1 <= vClock2)
        XCTAssertTrue(vClock2 <= vClock1)

        vClock2.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertTrue(vClock1 <= vClock2)
        XCTAssertTrue(vClock2 <= vClock1)

        vClock1.incrementClock(for: processB)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], 0)
        XCTAssertFalse(vClock1 <= vClock2)
        XCTAssertTrue(vClock2 <= vClock1)
    }

    func testConcurrent() {
        var vClock1 = VClock<String, Int>()

        let incrementProcessAOperation1 = vClock1.makeIncrementClockOperation(for: processA)
        vClock1.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)

        var vClock2 = VClock<String, Int>()

        XCTAssertFalse(vClock1.isConcurrentTo(vClock2))
        XCTAssertFalse(vClock2.isConcurrentTo(vClock1))

        let incrementProcessBOperation1 = vClock2.makeIncrementClockOperation(for: processB)
        vClock2.apply(incrementProcessBOperation1)
        XCTAssertEqual(vClock2[processB], 1)

        XCTAssertTrue(vClock1.isConcurrentTo(vClock2))
        XCTAssertTrue(vClock2.isConcurrentTo(vClock1))

        vClock1.apply(incrementProcessBOperation1)
        XCTAssertEqual(vClock1[processB], 1)

        XCTAssertFalse(vClock1.isConcurrentTo(vClock2))
        XCTAssertFalse(vClock2.isConcurrentTo(vClock1))

        let incrementProcessCOperation1 = vClock1.makeIncrementClockOperation(for: processC)
        vClock1.apply(incrementProcessCOperation1)
        XCTAssertEqual(vClock1[processC], 1)

        XCTAssertFalse(vClock1.isConcurrentTo(vClock2))
        XCTAssertFalse(vClock2.isConcurrentTo(vClock1))
    }

    func testMerge() throws {
        var vClock1 = VClock<String, Int>()
        var vClock2 = VClock<String, Int>()
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock1[processB], zeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)
        XCTAssertEqual(vClock2[processB], zeroValue)

        try vClock1.merge(vClock2)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock1[processB], zeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)
        XCTAssertEqual(vClock2[processB], zeroValue)

        vClock2.incrementClock(for: processA)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock1[processB], zeroValue)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)

        try vClock1.merge(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], zeroValue)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)

        vClock1.incrementClock(for: processB)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)

        try vClock1.merge(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)
    }

    func testMergeThrowsIfClockZeroValueNotEqual() throws {
        var vClock1 = VClock<String, Int>(clockZeroValue: 0)
        let vClock2 = VClock<String, Int>(clockZeroValue: 1)

        XCTAssertThrowsError(try vClock1.merge(vClock2))
    }

    func testMerged() throws {
        var vClock1 = VClock<String, Int>()
        var vClock2 = VClock<String, Int>()
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock1[processB], zeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)
        XCTAssertEqual(vClock2[processB], zeroValue)

        let vClock3 = try vClock1.merged(vClock2)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock1[processB], zeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)
        XCTAssertEqual(vClock2[processB], zeroValue)
        XCTAssertEqual(vClock3[processA], zeroValue)
        XCTAssertEqual(vClock3[processB], zeroValue)

        vClock2.incrementClock(for: processA)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock1[processB], zeroValue)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)
        XCTAssertEqual(vClock3[processA], zeroValue)
        XCTAssertEqual(vClock3[processB], zeroValue)

        let vClock4 = try vClock1.merged(vClock2)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock1[processB], zeroValue)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)
        XCTAssertEqual(vClock3[processA], zeroValue)
        XCTAssertEqual(vClock3[processB], zeroValue)
        XCTAssertEqual(vClock4[processA], 1)
        XCTAssertEqual(vClock4[processB], zeroValue)

        vClock1.incrementClock(for: processB)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)
        XCTAssertEqual(vClock3[processA], zeroValue)
        XCTAssertEqual(vClock3[processB], zeroValue)
        XCTAssertEqual(vClock4[processA], 1)
        XCTAssertEqual(vClock4[processB], zeroValue)

        let vClock5 = try vClock1.merged(vClock2)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)
        XCTAssertEqual(vClock3[processA], zeroValue)
        XCTAssertEqual(vClock3[processB], zeroValue)
        XCTAssertEqual(vClock4[processA], 1)
        XCTAssertEqual(vClock4[processB], zeroValue)
        XCTAssertEqual(vClock5[processA], 1)
        XCTAssertEqual(vClock5[processB], 1)
    }

    func testMergedThrowsIfClockZeroValueNotEqual() throws {
        let vClock1 = VClock<String, Int>(clockZeroValue: 0)
        let vClock2 = VClock<String, Int>(clockZeroValue: 1)

        XCTAssertThrowsError(try vClock1.merged(vClock2))
    }

    func testFormGreatestLowerBound() throws {
        var vClock1 = VClock<String, Int>()
        var vClock2 = VClock<String, Int>()
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)

        vClock1.formGreatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)

        let incrementProcessAOperation1 = vClock1.incrementClock(for: processA)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], zeroValue)

        vClock1.formGreatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)

        vClock1.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        vClock2.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock2[processA], 1)

        vClock1.formGreatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], 1)

        let incrementProcessBOperation1 = vClock1.incrementClock(for: processB)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)

        vClock1.formGreatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], zeroValue)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)

        vClock1.apply(incrementProcessBOperation1)
        XCTAssertEqual(vClock1[processB], 1)

        vClock1.incrementClock(for: processB)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 2)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)

        vClock2.apply(incrementProcessBOperation1)
        XCTAssertEqual(vClock2[processB], 1)

        vClock1.formGreatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], 1)
    }

    func testFormGreatestLowerBoundWithSelfLessThanOtherZeroValue() throws {
        var vClock1 = VClock<String, Int>(clockZeroValue: 0)
        var vClock2 = VClock<String, Int>(clockZeroValue: 1)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock2[processA], 1)

        vClock1.formGreatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock2[processA], 1)

        let incrementProcessAOperation1 = vClock1.incrementClock(for: processA)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], 1)

        vClock1.formGreatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], 1)

        vClock1.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        vClock2.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock2[processA], 1)

        vClock1.formGreatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], 1)

        let incrementProcessBOperation1 = vClock1.incrementClock(for: processB)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], 1)

        vClock1.formGreatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], 1)

        vClock1.apply(incrementProcessBOperation1)
        XCTAssertEqual(vClock1[processB], 1)

        vClock1.incrementClock(for: processB)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 2)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], 1)

        vClock2.apply(incrementProcessBOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 2)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], 1)

        vClock1.formGreatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], 1)
    }

    func testFormGreatestLowerBoundWithOtherLessThanSelfZeroValue() throws {
        var vClock1 = VClock<String, Int>(clockZeroValue: 1)
        var vClock2 = VClock<String, Int>(clockZeroValue: 0)
        vClock2.incrementClock(for: processB)
        vClock2.incrementClock(for: processC)
        vClock2.incrementClock(for: processC)
        XCTAssertEqual(vClock1.clockZeroValue, 1)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock1[processC], 1)
        XCTAssertEqual(vClock2[processA], zeroValue)
        XCTAssertEqual(vClock2[processB], 1)
        XCTAssertEqual(vClock2[processC], 2)

        vClock1.formGreatestLowerBound(vClock2)
        XCTAssertEqual(vClock1.clockZeroValue, zeroValue)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock1[processC], 1)
        XCTAssertEqual(vClock2[processA], zeroValue)
        XCTAssertEqual(vClock2[processB], 1)
        XCTAssertEqual(vClock2[processC], 2)
    }

    func testGreatestLowerBound() throws {
        var vClock1 = VClock<String, Int>()
        var vClock2 = VClock<String, Int>()
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)

        let vClock3 = vClock1.greatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)
        XCTAssertEqual(vClock3[processA], zeroValue)

        let incrementProcessAOperation1 = vClock1.incrementClock(for: processA)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], zeroValue)

        let vClock4 = vClock1.greatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], zeroValue)
        XCTAssertEqual(vClock4[processA], zeroValue)

        vClock1.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        vClock2.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock2[processA], 1)

        let vClock5 = vClock1.greatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock5[processA], 1)

        let incrementProcessBOperation1 = vClock1.incrementClock(for: processB)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)

        let vClock6 = vClock1.greatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)
        XCTAssertEqual(vClock6[processA], 1)
        XCTAssertEqual(vClock6[processB], zeroValue)

        vClock1.apply(incrementProcessBOperation1)
        XCTAssertEqual(vClock1[processB], 1)

        vClock1.incrementClock(for: processB)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 2)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)

        vClock2.apply(incrementProcessBOperation1)
        XCTAssertEqual(vClock2[processB], 1)

        let vClock7 = vClock1.greatestLowerBound(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 2)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], 1)
        XCTAssertEqual(vClock7[processA], 1)
        XCTAssertEqual(vClock7[processB], 1)
    }

    func testForget() throws {
        var vClock1 = VClock<String, Int>()
        var vClock2 = VClock<String, Int>()
        XCTAssertTrue(vClock1.allClocksAtZeroValue)
        XCTAssertTrue(vClock2.allClocksAtZeroValue)

        vClock1.forget(vClock2)
        XCTAssertTrue(vClock1.allClocksAtZeroValue)
        XCTAssertTrue(vClock2.allClocksAtZeroValue)

        let incrementClock1ProcessA = vClock1.incrementClock(for: processA)
        XCTAssertEqual(vClock1[processA], 1)
        vClock2.apply(incrementClock1ProcessA)
        XCTAssertEqual(vClock2[processA], 1)

        vClock1.forget(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], 1)

        let incrementClock1ProcessB = vClock1.incrementClock(for: processB)
        XCTAssertEqual(vClock1[processB], 1)
        vClock2.apply(incrementClock1ProcessB)
        XCTAssertEqual(vClock2[processB], 1)

        vClock1.forget(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], 1)

        vClock2.incrementClock(for: processA)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 2)
        XCTAssertEqual(vClock2[processB], 1)

        vClock1.forget(vClock2)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 2)
        XCTAssertEqual(vClock2[processB], 1)
    }

    func testFormIntersection() throws {
        var vClock1 = VClock<String, Int>()
        var vClock2 = VClock<String, Int>()
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)

        try vClock1.formIntersection(vClock2)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)

        let incrementProcessAOperation1 = vClock1.makeIncrementClockOperation(for: processA)
        vClock1.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], zeroValue)

        try vClock1.formIntersection(vClock2)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)

        vClock1.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        vClock2.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock2[processA], 1)

        try vClock1.formIntersection(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], 1)

        let incrementProcessBOperation1 = vClock1.makeIncrementClockOperation(for: processB)
        vClock1.apply(incrementProcessBOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)

        try vClock1.formIntersection(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], zeroValue)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)
    }

    func testFormIntersectionThrowsIfClockZeroValueNotEqual() throws {
        var vClock1 = VClock<String, Int>(clockZeroValue: 0)
        let vClock2 = VClock<String, Int>(clockZeroValue: 1)

        XCTAssertThrowsError(try vClock1.formIntersection(vClock2))
    }

    func testIntersection() throws {
        var vClock1 = VClock<String, Int>()
        var vClock2 = VClock<String, Int>()
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)

        let vClock3 = try vClock1.intersection(vClock2)
        XCTAssertEqual(vClock1[processA], zeroValue)
        XCTAssertEqual(vClock2[processA], zeroValue)
        XCTAssertEqual(vClock3[processA], zeroValue)

        let incrementProcessAOperation1 = vClock1.makeIncrementClockOperation(for: processA)
        vClock1.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], zeroValue)

        let vClock4 = try vClock1.intersection(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], zeroValue)
        XCTAssertEqual(vClock4[processA], zeroValue)

        vClock1.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        vClock2.apply(incrementProcessAOperation1)
        XCTAssertEqual(vClock2[processA], 1)

        let vClock5 = try vClock1.intersection(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock5[processA], 1)

        let incrementProcessBOperation1 = vClock1.makeIncrementClockOperation(for: processB)
        vClock1.apply(incrementProcessBOperation1)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)

        let vClock6 = try vClock1.intersection(vClock2)
        XCTAssertEqual(vClock1[processA], 1)
        XCTAssertEqual(vClock1[processB], 1)
        XCTAssertEqual(vClock2[processA], 1)
        XCTAssertEqual(vClock2[processB], zeroValue)
        XCTAssertEqual(vClock6[processA], 1)
        XCTAssertEqual(vClock6[processB], zeroValue)
    }

    func testIntersectionThrowsIfClockZeroValueNotEqual() throws {
        let vClock1 = VClock<String, Int>(clockZeroValue: 0)
        let vClock2 = VClock<String, Int>(clockZeroValue: 1)

        XCTAssertThrowsError(try vClock1.intersection(vClock2))
    }

    func testCodable() throws {
        var vClock1 = VClock<UUID, Int>()
        vClock1.incrementClock(for: UUID())

        let jsonEncoder = JSONEncoder()
        let encodedJSONData = try jsonEncoder.encode(vClock1)

        let jsonDecoder = JSONDecoder()
        let vClock2 = try jsonDecoder.decode(VClock<UUID, Int>.self, from: encodedJSONData)
        XCTAssertEqual(vClock1, vClock2)
    }
}
