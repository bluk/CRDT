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

import CRDTSets

public final class TwoPhaseSetTests: XCTestCase {
    func testExample() throws {
        var twoPhaseSetA = TwoPhaseSet<Int>()
        let (insertedA1, insertedMemberA1) = twoPhaseSetA.insert(1)
        XCTAssertEqual(twoPhaseSetA.elements, [1])
        XCTAssertEqual(twoPhaseSetA.removedElements, [])
        XCTAssertTrue(insertedA1)
        XCTAssertEqual(insertedMemberA1, 1)

        let (insertedA23, insertedMemberA23) = twoPhaseSetA.insert(23)
        XCTAssertEqual(twoPhaseSetA.elements, [1, 23])
        XCTAssertEqual(twoPhaseSetA.removedElements, [])
        XCTAssertTrue(insertedA23)
        XCTAssertEqual(insertedMemberA23, 23)

        let (insertedA23Again, insertedMemberA23Again) = twoPhaseSetA.insert(23)
        XCTAssertEqual(twoPhaseSetA.elements, [1, 23])
        XCTAssertEqual(twoPhaseSetA.removedElements, [])
        XCTAssertFalse(insertedA23Again)
        XCTAssertEqual(insertedMemberA23Again, 23)

        let (removedMemberA23) = twoPhaseSetA.remove(23)
        XCTAssertEqual(twoPhaseSetA.elements, [1])
        XCTAssertEqual(twoPhaseSetA.removedElements, [23])
        XCTAssertEqual(removedMemberA23, 23)

        let (insertedA23AfterRemoval, insertedMemberA23AfterRemoval) = twoPhaseSetA.insert(23)
        XCTAssertEqual(twoPhaseSetA.elements, [1])
        XCTAssertEqual(twoPhaseSetA.removedElements, [23])
        XCTAssertFalse(insertedA23AfterRemoval)
        XCTAssertEqual(insertedMemberA23AfterRemoval, 23)

        var twoPhaseSetB = TwoPhaseSet<Int>()

        let (insertedB23, insertedMemberB23) = twoPhaseSetB.insert(23)
        XCTAssertEqual(twoPhaseSetB.elements, [23])
        XCTAssertEqual(twoPhaseSetB.removedElements, [])
        XCTAssertTrue(insertedB23)
        XCTAssertEqual(insertedMemberB23, 23)

        let (insertedB47, insertedMemberB47) = twoPhaseSetB.insert(47)
        XCTAssertEqual(twoPhaseSetB.elements, [23, 47])
        XCTAssertEqual(twoPhaseSetB.removedElements, [])
        XCTAssertTrue(insertedB47)
        XCTAssertEqual(insertedMemberB47, 47)

        try twoPhaseSetA.merge(twoPhaseSetA)
        XCTAssertEqual(twoPhaseSetA.elements, [1])
        XCTAssertEqual(twoPhaseSetA.removedElements, [23])
        XCTAssertEqual(twoPhaseSetB.elements, [23, 47])
        XCTAssertEqual(twoPhaseSetB.removedElements, [])

        try twoPhaseSetA.merge(twoPhaseSetB)
        XCTAssertEqual(twoPhaseSetA.elements, [1, 47])
        XCTAssertEqual(twoPhaseSetA.removedElements, [23])
        XCTAssertEqual(twoPhaseSetB.elements, [23, 47])
        XCTAssertEqual(twoPhaseSetB.removedElements, [])
    }

    func testLessThan() throws {
        let twoPhaseSetA = TwoPhaseSet<Int>(elements: [1, 23])
        let twoPhaseSetB = TwoPhaseSet<Int>(elements: [23])
        let twoPhaseSetC = TwoPhaseSet<Int>()
        XCTAssertFalse(twoPhaseSetA < twoPhaseSetB)
        XCTAssertFalse(twoPhaseSetA < twoPhaseSetC)
        XCTAssertFalse(twoPhaseSetA < twoPhaseSetA)

        XCTAssertTrue(twoPhaseSetB < twoPhaseSetA)
        XCTAssertFalse(twoPhaseSetB < twoPhaseSetC)
        XCTAssertFalse(twoPhaseSetB < twoPhaseSetB)

        XCTAssertTrue(twoPhaseSetC < twoPhaseSetA)
        XCTAssertTrue(twoPhaseSetC < twoPhaseSetB)
        XCTAssertFalse(twoPhaseSetC < twoPhaseSetC)
    }

    func testLessThanWithRemovedElements() throws {
        let twoPhaseSetA = TwoPhaseSet<Int>(elements: [1, 23], removedElements: [45])
        let twoPhaseSetB = TwoPhaseSet<Int>(elements: [23], removedElements: [96])
        let twoPhaseSetC = TwoPhaseSet<Int>(removedElements: [45])
        XCTAssertFalse(twoPhaseSetA < twoPhaseSetB)
        XCTAssertFalse(twoPhaseSetA < twoPhaseSetC)
        XCTAssertFalse(twoPhaseSetA < twoPhaseSetA)

        XCTAssertFalse(twoPhaseSetB < twoPhaseSetA)
        XCTAssertFalse(twoPhaseSetB < twoPhaseSetC)
        XCTAssertFalse(twoPhaseSetB < twoPhaseSetB)

        XCTAssertTrue(twoPhaseSetC < twoPhaseSetA)
        XCTAssertFalse(twoPhaseSetC < twoPhaseSetB)
        XCTAssertFalse(twoPhaseSetC < twoPhaseSetC)
    }

    func testLessThanEqual() throws {
        let twoPhaseSetA = TwoPhaseSet<Int>(elements: [1, 23])
        let twoPhaseSetB = TwoPhaseSet<Int>(elements: [23])
        let twoPhaseSetC = TwoPhaseSet<Int>()
        XCTAssertFalse(twoPhaseSetA <= twoPhaseSetB)
        XCTAssertFalse(twoPhaseSetA <= twoPhaseSetC)
        XCTAssertTrue(twoPhaseSetA <= twoPhaseSetA)

        XCTAssertTrue(twoPhaseSetB <= twoPhaseSetA)
        XCTAssertFalse(twoPhaseSetB <= twoPhaseSetC)
        XCTAssertTrue(twoPhaseSetB <= twoPhaseSetB)

        XCTAssertTrue(twoPhaseSetC <= twoPhaseSetA)
        XCTAssertTrue(twoPhaseSetC <= twoPhaseSetB)
        XCTAssertTrue(twoPhaseSetC <= twoPhaseSetC)
    }

    func testLessThanEqualWithRemovedElements() throws {
        let twoPhaseSetA = TwoPhaseSet<Int>(elements: [1, 23], removedElements: [45])
        let twoPhaseSetB = TwoPhaseSet<Int>(elements: [23], removedElements: [96])
        let twoPhaseSetC = TwoPhaseSet<Int>(removedElements: [45])
        XCTAssertFalse(twoPhaseSetA <= twoPhaseSetB)
        XCTAssertFalse(twoPhaseSetA <= twoPhaseSetC)
        XCTAssertTrue(twoPhaseSetA <= twoPhaseSetA)

        XCTAssertFalse(twoPhaseSetB <= twoPhaseSetA)
        XCTAssertFalse(twoPhaseSetB <= twoPhaseSetC)
        XCTAssertTrue(twoPhaseSetB <= twoPhaseSetB)

        XCTAssertTrue(twoPhaseSetC <= twoPhaseSetA)
        XCTAssertFalse(twoPhaseSetC <= twoPhaseSetB)
        XCTAssertTrue(twoPhaseSetC <= twoPhaseSetC)
    }

}
