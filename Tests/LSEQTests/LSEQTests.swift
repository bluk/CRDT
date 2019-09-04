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

import LSEQ

final class LSEQTests: XCTestCase {
    let elementCount = 1000

    typealias LSEQType = LSEQIdentifier16Source16Clock64

    func testInit() {
        let lseq = LSEQType<Int>(
            source: 42,
            clock: 0
        )
        XCTAssertEqual(lseq.source, 42)
        XCTAssertEqual(lseq.clock, 0)

        XCTAssertEqual(lseq.count, 0)
    }

    func testInsertElement() {
        var lseq = LSEQType<Int>(
            source: 42,
            clock: 0
        )
        _ = lseq.insertAndMakeOperation(1, at: 0)

        XCTAssertEqual(lseq.source, 42)
        XCTAssertEqual(lseq.clock, 1)
        XCTAssertEqual(lseq.count, 1)

        XCTAssertEqual(lseq[0], 1)
    }

    func testInsertElementCountAtBeginning() {
        var lseq = LSEQType<Int>(
            source: 42,
            clock: 0
        )
        for index in 0..<self.elementCount {
            _ = lseq.insertAndMakeOperation(index, at: 0)
        }
        XCTAssertEqual(lseq.count, self.elementCount)

        for index in 0..<self.elementCount {
            XCTAssertEqual(self.elementCount - 1 - index, lseq[index])
        }
    }

    func testInsertElementCountAtEnd() {
        var lseq = LSEQType<Int>(
            source: 42,
            clock: 0
        )
        for index in 0..<self.elementCount {
            _ = lseq.insertAndMakeOperation(index, at: lseq.count)
        }
        XCTAssertEqual(lseq.count, self.elementCount)

        for index in 0..<self.elementCount {
            XCTAssertEqual(index, lseq[index])
        }

        var clock = 0
        for element in lseq {
            XCTAssertEqual(element, clock)
            clock += 1
        }
    }

    func testInsertElementCountInRandomIndex() {
        var lseq = LSEQType<Int>(
            source: 42,
            clock: 0
        )
        let count = self.elementCount
        for element in 0..<count {
            let index = Int.random(in: 0...lseq.count)
            _ = lseq.insertAndMakeOperation(element, at: index)
            if lseq[index] != element {
                print("Inserting into: \(index)")
                print("Found element: \(lseq[index])")
                print("Expected element: \(element)")
                print(lseq)
            }
            XCTAssertEqual(lseq[index], element)
        }
        XCTAssertEqual(lseq.count, count)
    }

    func testInsertAndRemove() {
        var lseq = LSEQType<Int>(
            source: 42,
            clock: 0
        )
        _ = lseq.insertAndMakeOperation(1, at: 0)
        XCTAssertEqual(lseq.source, 42)
        XCTAssertEqual(lseq.clock, 1)
        XCTAssertEqual(lseq.count, 1)

        XCTAssertEqual(lseq[0], 1)
        _ = lseq.removeAndMakeOperation(at: 0)

        XCTAssertEqual(lseq.count, 0)
        XCTAssertTrue(lseq.isEmpty)
    }

    func testInsertAndRemoveElementCount() {
        var lseq = LSEQType<Int>(
            source: 42,
            clock: 0
        )
        for index in 0..<self.elementCount {
            _ = lseq.insertAndMakeOperation(index, at: Int.random(in: 0...index))
        }
        XCTAssertEqual(lseq.count, self.elementCount)
        for index in 0..<self.elementCount {
            _ = lseq.removeAndMakeOperation(at: Int.random(in: 0..<self.elementCount - index))
        }
        XCTAssertEqual(lseq.count, 0)
    }

    func testInsertionPattern1() {
        var lseq = LSEQType<Int>(
            source: 42,
            clock: 0
        )

        let position0 = LSEQType<Int>.PositionType(
            segments: [
                LSEQType<Int>.PositionType.Segment(id: 1, source: 42),
            ],
            clock: 1
        )

        lseq.apply(LSEQType<Int>.Operation(kind: .insert, position: position0, element: 0))
        XCTAssertEqual(lseq[0], 0)

        let position1 = LSEQType<Int>.PositionType(
            segments: [
                LSEQType<Int>.PositionType.Segment(id: 0, source: LSEQType<Int>.PositionType.Segment.Identifier.min),
                LSEQType<Int>.PositionType.Segment(id: 65533, source: 42),
            ],
            clock: 2
        )
        lseq.apply(LSEQType<Int>.Operation(kind: .insert, position: position1, element: 1))
        XCTAssertEqual(lseq[0], 1)
        XCTAssertEqual(lseq[1], 0)

        let position2 = LSEQType<Int>.PositionType(
            segments: [
                LSEQType<Int>.PositionType.Segment(id: 0, source: LSEQType<Int>.PositionType.Segment.Identifier.min),
                LSEQType<Int>.PositionType.Segment(id: 65534, source: 42),
            ],
            clock: 3
        )
        lseq.apply(LSEQType<Int>.Operation(kind: .insert, position: position2, element: 2))
        XCTAssertEqual(lseq[0], 1)
        XCTAssertEqual(lseq[1], 2)
        XCTAssertEqual(lseq[2], 0)

        let pCoordinates = lseq.storage[0].position
        let qCoordinates = lseq.storage[1].position
        XCTAssertEqual(pCoordinates, position1)
        XCTAssertEqual(qCoordinates, position2)

        _ = lseq.insertAndMakeOperation(4, at: 1)

        XCTAssertEqual(lseq[0], 1)
        XCTAssertEqual(lseq[1], 4)
        XCTAssertEqual(lseq[2], 2)
        XCTAssertEqual(lseq[3], 0)
    }

    func testInsertionPattern2() {
        var lseq = LSEQType<Int>(
            source: 42,
            clock: 0
        )

        let position0 = LSEQType<Int>.PositionType(
            segments: [
                LSEQType<Int>.PositionType.Segment(id: 7, source: 42),
            ],
            clock: 1
        )

        lseq.apply(LSEQType<Int>.Operation(kind: .insert, position: position0, element: 0))
        XCTAssertEqual(lseq[0], 0)

        let position1 = LSEQType<Int>.PositionType(
            segments: [
                LSEQType<Int>.PositionType.Segment(id: 6, source: 42),
            ],
            clock: 2
        )

        lseq.apply(LSEQType<Int>.Operation(kind: .insert, position: position1, element: 1))
        XCTAssertEqual(lseq[0], 1)
        XCTAssertEqual(lseq[1], 0)

        let position2 = LSEQType<Int>.PositionType(
            segments: [
                LSEQType<Int>.PositionType.Segment(id: 6, source: 42),
                LSEQType<Int>.PositionType.Segment(id: 65526, source: 42),
            ],
            clock: 3
        )
        lseq.apply(LSEQType<Int>.Operation(kind: .insert, position: position2, element: 2))
        XCTAssertEqual(lseq[0], 1)
        XCTAssertEqual(lseq[1], 2)
        XCTAssertEqual(lseq[2], 0)

        let position3 = LSEQType<Int>.PositionType(
            segments: [
                LSEQType<Int>.PositionType.Segment(id: 6, source: 42),
                LSEQType<Int>.PositionType.Segment(id: 65524, source: 42),
            ],
            clock: 4
        )

        lseq.apply(LSEQType<Int>.Operation(kind: .insert, position: position3, element: 3))
        XCTAssertEqual(lseq[0], 1)
        XCTAssertEqual(lseq[1], 3)
        XCTAssertEqual(lseq[2], 2)
        XCTAssertEqual(lseq[3], 0)

        let pCoordinates = lseq.storage[1].position
        let qCoordinates = lseq.storage[2].position
        XCTAssertEqual(pCoordinates, position3)
        XCTAssertEqual(qCoordinates, position2)

        _ = lseq.insertAndMakeOperation(4, at: 2)

        XCTAssertEqual(lseq[0], 1)
        XCTAssertEqual(lseq[1], 3)
        XCTAssertEqual(lseq[2], 4)
        XCTAssertEqual(lseq[3], 2)
        XCTAssertEqual(lseq[4], 0)
    }

    func testApplySameInsertOperation() {
        var lseq = LSEQType<Int>(
            source: 42,
            clock: 0
        )

        let position0 = LSEQType<Int>.PositionType(
            segments: [
                LSEQType<Int>.PositionType.Segment(id: 7, source: 42),
            ],
            clock: 1
        )

        lseq.apply(LSEQType<Int>.Operation(kind: .insert, position: position0, element: 0))
        XCTAssertEqual(lseq[0], 0)
        XCTAssertEqual(lseq.count, 1)

        lseq.apply(LSEQType<Int>.Operation(kind: .insert, position: position0, element: Int.max))
        XCTAssertEqual(lseq[0], 0)
        XCTAssertEqual(lseq.count, 1)

        lseq.apply(LSEQType<Int>.Operation(kind: .insert, position: position0, element: 0))
        XCTAssertEqual(lseq[0], 0)
        XCTAssertEqual(lseq.count, 1)

        let position1 = LSEQType<Int>.PositionType(
            segments: [
                LSEQType<Int>.PositionType.Segment(id: 8, source: 42),
            ],
            clock: 2
        )
        lseq.apply(LSEQType<Int>.Operation(kind: .insert, position: position1, element: 1))
        XCTAssertEqual(lseq[0], 0)
        XCTAssertEqual(lseq[1], 1)
        XCTAssertEqual(lseq.count, 2)

        lseq.apply(LSEQType<Int>.Operation(kind: .insert, position: position1, element: Int.max))
        XCTAssertEqual(lseq[0], 0)
        XCTAssertEqual(lseq[1], 1)
        XCTAssertEqual(lseq.count, 2)
    }

    func testApplySameRemoveOperation() {
        var lseq = LSEQType<Int>(
            source: 42,
            clock: 0
        )

        let position0 = LSEQType<Int>.PositionType(
            segments: [
                LSEQType<Int>.PositionType.Segment(id: 7, source: 42),
            ],
            clock: 1
        )
        lseq.apply(LSEQType<Int>.Operation(kind: .insert, position: position0, element: 0))
        XCTAssertEqual(lseq[0], 0)
        XCTAssertEqual(lseq.count, 1)

        let (elementRemoved0, removeOperation0) = lseq.removeAndMakeOperation(at: 0)
        XCTAssertEqual(elementRemoved0, 0)
        XCTAssertEqual(removeOperation0.position, position0)
        XCTAssertEqual(lseq.count, 0)
        XCTAssertTrue(lseq.isEmpty)

        lseq.apply(removeOperation0)
        XCTAssertEqual(lseq.count, 0)
        XCTAssertTrue(lseq.isEmpty)
    }

    func testMergeBehavior1() {
        var lseq0 = LSEQType<Character>(
            source: 42,
            clock: 0
        )

        let insertOperation0_0 = lseq0.insertAndMakeOperation("a", at: 0)
        let insertOperation0_1 = lseq0.insertAndMakeOperation("b", at: 1)
        let insertOperation0_2 = lseq0.insertAndMakeOperation("c", at: 2)

        var lseq1 = LSEQType<Character>(
            source: 512,
            clock: 0
        )
        lseq1.apply(insertOperation0_0)

        let insertOperation1_0 = lseq1.insertAndMakeOperation("d", at: 0)

        lseq1.apply(insertOperation0_1)

        let insertOperation1_1 = lseq1.insertAndMakeOperation("e", at: 1)
        let insertOperation1_2 = lseq1.insertAndMakeOperation("f", at: 2)

        lseq1.apply(insertOperation0_2)

        lseq0.apply(insertOperation1_0)
        lseq0.apply(insertOperation1_1)
        lseq0.apply(insertOperation1_2)

        XCTAssertEqual(String(lseq0), String(lseq1))
        XCTAssertEqual(String(lseq0), "defabc")
    }

    func testMergeBehavior2() {
        var lseq0 = LSEQType<Character>(
            source: 42,
            clock: 0
        )

        let insertOperation0_0 = lseq0.insertAndMakeOperation("a", at: 0)

        let insertOperation0_1 = lseq0.insertAndMakeOperation("b", at: 1)
        let insertOperation0_2 = lseq0.insertAndMakeOperation("c", at: 2)

        var lseq1 = LSEQType<Character>(
            source: 512,
            clock: 0
        )
        lseq1.apply(insertOperation0_0)

        let insertOperation1_0 = lseq1.insertAndMakeOperation("d", at: 1)

        let insertOperation1_1 = lseq1.insertAndMakeOperation("e", at: 2)
        let insertOperation1_2 = lseq1.insertAndMakeOperation("f", at: 3)

        lseq1.apply(insertOperation0_0)
        lseq1.apply(insertOperation0_2)
        lseq1.apply(insertOperation0_1)

        lseq0.apply(insertOperation1_2)
        lseq0.apply(insertOperation1_1)
        lseq0.apply(insertOperation1_0)

        XCTAssertEqual(String(lseq0), String(lseq1))
    }

    func testMakeDifferenceOperations1() {
        var lseq0 = LSEQType<Character>(
            source: 42,
            clock: 0
        )
        let insertOperation0_0 = lseq0.insertAndMakeOperation("a", at: 0)
        let insertOperation0_1 = lseq0.insertAndMakeOperation("b", at: 1)
        let insertOperation0_2 = lseq0.insertAndMakeOperation("c", at: 2)

        var lseq1 = LSEQType<Character>(
            source: 512,
            clock: 0
        )
        lseq1.apply(insertOperation0_1)

        let differenceOperations = lseq0.makeDifferenceOperations(from: lseq1)

        XCTAssertEqual(differenceOperations, [
            insertOperation0_0,
            insertOperation0_2,
        ])
    }

    func testMakeDifferenceOperations2() {
        var lseq0 = LSEQType<Character>(
            source: 42,
            clock: 0
        )
        let insertOperation0_0 = lseq0.insertAndMakeOperation("a", at: 0)
        let insertOperation0_1 = lseq0.insertAndMakeOperation("b", at: 1)
        _ = lseq0.insertAndMakeOperation("c", at: 2)
        let insertOperation0_3 = lseq0.insertAndMakeOperation("d", at: 3)

        _ = lseq0.removeAndMakeOperation(at: 2)

        var lseq1 = LSEQType<Character>(
            source: 512,
            clock: 0
        )
        lseq1.apply(insertOperation0_1)

        let differenceOperations = lseq0.makeDifferenceOperations(from: lseq1)

        XCTAssertEqual(differenceOperations, [
            insertOperation0_0,
            insertOperation0_3,
        ])
    }

    func testMakeDifferenceOperations3() {
        var lseq0 = LSEQType<Character>(
            source: 42,
            clock: 0
        )
        let insertOperation0_0 = lseq0.insertAndMakeOperation("a", at: 0)
        let insertOperation0_1 = lseq0.insertAndMakeOperation("b", at: 1)
        let insertOperation0_2 = lseq0.insertAndMakeOperation("c", at: 2)
        let insertOperation0_3 = lseq0.insertAndMakeOperation("d", at: 3)

        let (_, removeOperation0_1) = lseq0.removeAndMakeOperation(at: 1)

        var lseq1 = LSEQType<Character>(
            source: 512,
            clock: 0
        )
        lseq1.apply(insertOperation0_1)

        let differenceOperations = lseq0.makeDifferenceOperations(from: lseq1)

        XCTAssertEqual(differenceOperations, [
            insertOperation0_0,
            removeOperation0_1,
            insertOperation0_2,
            insertOperation0_3,
        ])
    }
}
