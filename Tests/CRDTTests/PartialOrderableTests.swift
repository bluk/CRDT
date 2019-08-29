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

public final class PartialOrderableTests: XCTestCase {
    struct A: PartialOrderable {
        let value: Int

        static func < (lhs: A, rhs: A) -> Bool {
            return lhs.value < rhs.value
        }

        static func <= (lhs: A, rhs: A) -> Bool {
            return lhs.value <= rhs.value
        }
    }

    func testPartialOrderableLessThan() throws {
        let a1 = A(value: 2)
        let a2 = A(value: 3)

        XCTAssertTrue(a1 < a2)
        XCTAssertTrue(a1 <= a2)
    }

    func testPartialOrderableNotLessThan() throws {
        let a1 = A(value: 4)
        let a2 = A(value: 3)

        XCTAssertFalse(a1 < a2)
        XCTAssertFalse(a1 <= a2)
    }

    func testPartialOrderableEqual() throws {
        let a1 = A(value: 2)
        let a2 = A(value: 2)

        XCTAssertEqual(a1, a2)
    }

    func testPartialOrderableNotEqual() throws {
        let a1 = A(value: 2)
        let a2 = A(value: 3)

        XCTAssertNotEqual(a1, a2)
    }

    struct X: PartialOrderable, Comparable {
        let value: Int

        static func < (lhs: X, rhs: X) -> Bool {
            return lhs.value < rhs.value
        }
    }

    func testPartialOrderableAndComparableLessThan() throws {
        let x1 = X(value: 2)
        let x2 = X(value: 3)

        XCTAssertTrue(x1 < x2)
        XCTAssertTrue(x1 <= x2)
    }
}
