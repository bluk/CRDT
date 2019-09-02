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

public final class GSetTests: XCTestCase {
    func testExample() throws {
        var gsetA = GSet<Int>()

        let (insertedA1, insertedMemberA1) = gsetA.insert(1)
        XCTAssertEqual(gsetA.elements, [1])
        XCTAssertTrue(insertedA1)
        XCTAssertEqual(insertedMemberA1, 1)

        let (insertedA23, insertedMemberA23) = gsetA.insert(23)
        XCTAssertEqual(gsetA.elements, [1, 23])
        XCTAssertTrue(insertedA23)
        XCTAssertEqual(insertedMemberA23, 23)

        let (insertedA23Again, insertedMemberA23Again) = gsetA.insert(23)
        XCTAssertEqual(gsetA.elements, [1, 23])
        XCTAssertFalse(insertedA23Again)
        XCTAssertEqual(insertedMemberA23Again, 23)

        var gsetB = GSet<Int>()

        let (insertedB23, insertedMemberB23) = gsetB.insert(23)
        XCTAssertEqual(gsetB.elements, [23])
        XCTAssertTrue(insertedB23)
        XCTAssertEqual(insertedMemberB23, 23)

        let (insertedB47, insertedMemberB47) = gsetB.insert(47)
        XCTAssertEqual(gsetB.elements, [23, 47])
        XCTAssertTrue(insertedB47)
        XCTAssertEqual(insertedMemberB47, 47)

        let gsetC = gsetA.union(gsetB)
        XCTAssertEqual(gsetA.elements, [1, 23])
        XCTAssertEqual(gsetB.elements, [23, 47])
        XCTAssertEqual(gsetC.elements, [23, 47, 1])

        gsetA.formUnion(gsetA)
        XCTAssertEqual(gsetA.elements, [1, 23])
        XCTAssertEqual(gsetB.elements, [23, 47])
        XCTAssertEqual(gsetC.elements, [23, 47, 1])

        gsetA.formUnion(gsetB)
        XCTAssertEqual(gsetA.elements, [1, 23, 47])
        XCTAssertEqual(gsetB.elements, [23, 47])
        XCTAssertEqual(gsetC.elements, [23, 47, 1])
    }

    func testLessThan() throws {
        let gsetA = GSet<Int>([1, 23])
        let gsetB = GSet<Int>([23])
        let gsetC = GSet<Int>()
        XCTAssertFalse(gsetA < gsetB)
        XCTAssertFalse(gsetA < gsetC)
        XCTAssertFalse(gsetA < gsetA)

        XCTAssertTrue(gsetB < gsetA)
        XCTAssertFalse(gsetB < gsetC)
        XCTAssertFalse(gsetB < gsetB)

        XCTAssertTrue(gsetC < gsetA)
        XCTAssertTrue(gsetC < gsetB)
        XCTAssertFalse(gsetC < gsetC)
    }

    func testLessThanEqual() throws {
        let gsetA = GSet<Int>([1, 23])
        let gsetB = GSet<Int>([23])
        let gsetC = GSet<Int>()
        XCTAssertFalse(gsetA <= gsetB)
        XCTAssertFalse(gsetA <= gsetC)
        XCTAssertTrue(gsetA <= gsetA)

        XCTAssertTrue(gsetB <= gsetA)
        XCTAssertFalse(gsetB <= gsetC)
        XCTAssertTrue(gsetB <= gsetB)

        XCTAssertTrue(gsetC <= gsetA)
        XCTAssertTrue(gsetC <= gsetB)
        XCTAssertTrue(gsetC <= gsetC)
    }
}
