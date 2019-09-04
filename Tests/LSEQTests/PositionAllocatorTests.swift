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

enum CompareResult {
    case lessThan
    case equal
    case greaterThan
}

internal func compare<S: PositionSegment>(lhs: [S], rhs: [S]) -> CompareResult {
    let lhsCount = lhs.count
    let rhsCount = rhs.count
    let minCount = min(lhsCount, rhsCount)

    for index in 0..<minCount {
        let lhsSegment = lhs[index]
        let rhsSegment = rhs[index]

        if lhsSegment < rhsSegment {
            return CompareResult.lessThan
        } else if lhsSegment == rhsSegment {
            continue
        } else {
            return CompareResult.greaterThan
        }
    }

    if lhsCount == rhsCount {
        return CompareResult.equal
    } else if lhsCount < rhsCount {
        return CompareResult.lessThan
    }

    return CompareResult.greaterThan
}

final class PositionAllocatorTests: XCTestCase {
    typealias PositionType = PositionIdentifier16Source16Clock64

    let boundary: PositionType.Segment.Identifier = 10
    let samePosition: PositionType.Segment.Identifier = 9

    // MARK: Difference at Same Level, No Additional Segments

    func testPositionAllocate_differenceGreaterThanBoundary_level0() {
        let p = PositionType(segments: [
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 1)
        XCTAssertTrue(p.segments[0].id < allocated[0].id)
        XCTAssertTrue(allocated[0].id <= p.segments[0].id + boundary)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_differenceGreaterThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(q.segments[1].id - boundary <= allocated[1].id)
        XCTAssertTrue(allocated[1].id < q.segments[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_differenceGreaterThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(p.segments[2].id < allocated[2].id)
        XCTAssertTrue(allocated[2].id <= p.segments[2].id + boundary)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_differenceLessThanBoundary_level0() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 5, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 1)
        XCTAssertTrue(p.segments[0].id < allocated[0].id)
        XCTAssertTrue(allocated[0].id < q.segments[0].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_differenceLessThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 5, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(p.segments[1].id < allocated[1].id)
        XCTAssertTrue(allocated[1].id < q.segments[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_differenceLessThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 5, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(p.segments[2].id < allocated[2].id)
        XCTAssertTrue(allocated[2].id < q.segments[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_differenceOnly1_level0() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)
        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_differenceOnly1_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)
        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_differenceOnly1_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)
        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_differenceAtMax_level0() {
        let p = PositionType(segments: [
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)
        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_differenceAtMin_level0() {
        let p = PositionType(segments: [
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)
        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_differenceAtMax_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)
        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_differenceAtMin_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)
        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_differenceAtMax_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)
        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_differenceAtMin_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)
        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    // MARK: P Segment Count Less Than Q Segment Count

    func testPositionAllocate_PLessSegmentsThanQ_differenceGreaterThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < q.segments[1].id)
        XCTAssertTrue(q.segments[1].id - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQ_differenceGreaterThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id < q.segments[2].id)
        XCTAssertTrue(q.segments[2].id - boundary <= allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQ_differenceLessThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary / 2, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        if allocated.count == 2 {
            XCTAssertEqual(allocated.count, 2)
            XCTAssertEqual(allocated[0], p.segments[0])

            XCTAssertTrue(allocated[1].id < q.segments[1].id)
            XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[1].id)
        } else {
            // TODO: This never hits in the current algorithm
            XCTAssertEqual(allocated.count, 3)
            XCTAssertEqual(allocated[0], p.segments[0])
            XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.min)

            XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
            XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)
        }

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQ_differenceLessThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary / 2, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id < q.segments[2].id)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQ_qAtMax_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQ_qAtMaxMinusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max - 1)
        XCTAssertTrue(PositionType.Segment.Identifier.max - 1 - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQ_qAtMin_level1_illegalState() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], q.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.greaterThan)
    }

    func testPositionAllocate_PLessSegmentsThanQ_qAtMinPlusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQ_qAtMax_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQ_qAtMaxMinusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQ_qAtMin_level2_illegalState() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], q.segments[2])

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.greaterThan)
    }

    func testPositionAllocate_PLessSegmentsThanQ_qAtMinPlusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    // MARK: Q Segment Count Greater Than P Segment Count + 1

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_differenceGreaterThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary + boundary / 2, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], q.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_differenceLessThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary / 2, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], q.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary / 2)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_min_level1_illegalState() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], q.segments[1])
        XCTAssertEqual(allocated[2], q.segments[2])

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.greaterThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_minPlusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], q.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_max_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], q.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_maxMinusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], q.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_differenceGreaterThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary + boundary / 2, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_differenceSmallerThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary / 2, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_min_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_minPlusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_max_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_maxMinusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_differenceGreaterThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary + boundary / 2, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.min + boundary + boundary / 2)
        XCTAssertTrue(PositionType.Segment.Identifier.min + boundary / 2 <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_differenceSmallerThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary / 2, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.min + boundary / 2)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_min_level2_illegalState() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 5)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.min)
        XCTAssertEqual(allocated[3].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[4].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[4].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.greaterThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_minPlusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 5)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.min)
        XCTAssertEqual(allocated[3].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[4].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[4].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_max_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_min_maxMinusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max - 1)
        XCTAssertTrue(PositionType.Segment.Identifier.max - 1 - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_differenceGreaterThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary + boundary / 2, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_differenceLessThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary / 2, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_min_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_minPlusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_max_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PLessSegmentsThanQByMoreThan1_minPlusOne_maxMinusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.min)

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    // MARK: P Segments Count Is Greater Than Q Segments Count

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_differenceGreaterThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary + boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_differenceGreaterThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary + boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary + boundary / 2 + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min + boundary + boundary / 2 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_differenceLessThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id <= PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary / 2 < allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_differenceLessThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary / 2 + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min + boundary / 2 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_max_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_maxMinusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.max)
        // TODO: This is not optimal. Should just use max

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_max_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_maxMinusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        // TODO: This is not optimal. Should use the maximum ID.

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        // TODO: This is not optimal. Should use the maximum ID.

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        // TODO: This is not optimal. Should use the maximum ID.

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + 1 + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min + 1 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_differenceGreaterThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary + boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_differenceLessThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_min_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_minPlusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_max_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_maxMinusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_differenceGreaterThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary + boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_differenceLessThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_min_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_minPlusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_max_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_maxMinusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_differenceGreaterThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary + boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_differenceLessThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_min_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_minPlusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_max_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_min_maxMinusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_differenceGreaterThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary + boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + 1 + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min + 1 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_differenceLessThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + 1 + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min + 1 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_min_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + 1 + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min + 1 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_minPlusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + 1 + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min + 1 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_max_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + 1 + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min + 1 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsGreaterThanQ_differenceOnly1_minPlusOne_maxMinusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + 1 + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min + 1 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    // MARK: P Segment Count Less than Q Segment Count - Difference Only One

    func testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_differenceGreaterThanBoundary_level0() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary + boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_differenceGreaterThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary + boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary + boundary / 2 + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min + boundary + boundary / 2 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_differenceLessThanBoundary_level0() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_differenceLessThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary / 2 + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min + boundary / 2 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_max_level0() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.max)

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_maxMinusOne_level0() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.max)

        // TODO: This is not optimal. Should end with max

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_min_level0() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_minPlusOne_level0() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 2)
        XCTAssertEqual(allocated[0], p.segments[0])

        XCTAssertTrue(allocated[1].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[1].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_max_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_maxMinusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2].id, PositionType.Segment.Identifier.max - 1)

        // TODO: This is not optimal. Should use max

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_min_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsLessThanQ_differenceOnly1_minPlusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + 1 + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min + 1 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    // MARK: P Segment Count Equal To Q Segment Count But Difference Earlier

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_differenceGreaterThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - boundary / 2 - boundary, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.max - boundary / 2)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary / 2 - boundary < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_differenceLessThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary / 2 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_min_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_minPlusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + 1 + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min + 1 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_max_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_maxMinusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        // TODO: This is not optimal. Should use the max

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_differenceGreaterThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - boundary / 2 - boundary, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.max)

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.max - boundary / 2)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary / 2 - boundary < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_differenceLessThanBoundary_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.max)

        XCTAssertTrue(allocated[2].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary / 2 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_min_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.max)

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_minPlusOne_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 3)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.max)

        XCTAssertTrue(allocated[2].id <= PositionType.Segment.Identifier.min + 1 + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min + 1 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_max_level1() {
        let p = PositionType(segments: [
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1].id, PositionType.Segment.Identifier.max)
        XCTAssertEqual(allocated[2], p.segments[2])

        // TODO: Not optimal

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_differenceGreaterThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - boundary / 2 - boundary, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        XCTAssertTrue(allocated[3].id <= PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_differenceLessThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary / 2 < allocated[2].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_min_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_minPlusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_max_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 5)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])
        XCTAssertEqual(allocated[3], p.segments[3])

        XCTAssertTrue(allocated[4].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[4].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_max_maxMinusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 5)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])
        XCTAssertEqual(allocated[3].id, PositionType.Segment.Identifier.max)

        XCTAssertTrue(allocated[4].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[4].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_differenceGreaterThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - boundary / 2 - boundary, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        // TODO: This is not optimal. Should have just used max.

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_differenceLessThanBoundary_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - boundary / 2, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        // TODO: This is not optimal. Should have just used max.

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary / 2 < allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_min_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        // TODO: This is not optimal. Should have just used max.

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_minPlusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min + 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 4)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])

        // TODO: This is not optimal. Should have just used max.

        XCTAssertTrue(allocated[3].id < PositionType.Segment.Identifier.max)
        XCTAssertTrue(PositionType.Segment.Identifier.max - boundary <= allocated[3].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_max_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 5)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])
        XCTAssertEqual(allocated[3], p.segments[3])

        // TODO: This is not optimal. Should have just used max.

        XCTAssertTrue(allocated[4].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[4].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }

    func testPositionAllocate_PSegmentsEqualToQ_differenceOnly1_maxMinusOne_maxMinusOne_level2() {
        let p = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 2, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.max - 1, source: 0),
        ], clock: 0)

        let q = PositionType(segments: [
            PositionType.Segment(id: samePosition, source: 0),
            PositionType.Segment(id: 3, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
            PositionType.Segment(id: PositionType.Segment.Identifier.min, source: 0),
        ], clock: 0)

        let allocated =
            PositionType.allocateBetween(p: p, q: q, boundary: boundary, source: 0)

        XCTAssertEqual(allocated.count, 5)
        XCTAssertEqual(allocated[0], p.segments[0])
        XCTAssertEqual(allocated[1], p.segments[1])
        XCTAssertEqual(allocated[2], p.segments[2])
        XCTAssertEqual(allocated[3].id, PositionType.Segment.Identifier.max)

        // TODO: This is not optimal. Should have just used max.

        XCTAssertTrue(allocated[4].id <= PositionType.Segment.Identifier.min + boundary)
        XCTAssertTrue(PositionType.Segment.Identifier.min < allocated[4].id)

        XCTAssertEqual(compare(lhs: allocated, rhs: p.segments), CompareResult.greaterThan)
        XCTAssertEqual(compare(lhs: allocated, rhs: q.segments), CompareResult.lessThan)
    }
}
