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

import CRDT

/// A positive-negative counter. Actors can increment and decrement their counter value.
public struct PNCounter<Actor: Equatable>: PartialOrderable {
    public struct CRDTOperation {
        // swiftlint:disable nesting

        public enum Direction: Int8, Codable {
            case positive = 1
            case negative = -1
        }

        // swiftlint:enable nesting

        public let direction: Direction
        public let counterOperation: GCounter<Actor>.CRDTOperation
    }

    var positiveValues: GCounter<Actor>
    var negativeValues: GCounter<Actor>

    public init() {
        self.positiveValues = GCounter<Actor>()
        self.negativeValues = GCounter<Actor>()
    }

    public var value: Int64 {
        return Int64(self.positiveValue) - Int64(self.negativeValue)
    }

    public var positiveValue: GCounter<Actor>.Value {
        return self.positiveValues.value
    }

    public var negativeValue: GCounter<Actor>.Value {
        return self.negativeValues.value
    }

    public func makeIncrementCounterOperation(for actor: Actor) -> CRDTOperation {
        return CRDTOperation(
            direction: CRDTOperation.Direction.positive,
            counterOperation: self.positiveValues.makeIncrementCounterOperation(for: actor)
        )
    }

    @discardableResult
    public mutating func incrementCounter(for actor: Actor) -> CRDTOperation {
        let operation = self.makeIncrementCounterOperation(for: actor)
        self.apply(operation)
        return operation
    }

    public func makeDecrementCounterOperation(for actor: Actor) -> CRDTOperation {
        return CRDTOperation(
            direction: CRDTOperation.Direction.negative,
            counterOperation: self.negativeValues.makeIncrementCounterOperation(for: actor)
        )
    }

    @discardableResult
    public mutating func decrementCounter(for actor: Actor) -> CRDTOperation {
        let operation = self.makeDecrementCounterOperation(for: actor)
        self.apply(operation)
        return operation
    }

    public static func < (lhs: PNCounter<Actor>, rhs: PNCounter<Actor>) -> Bool {
        return
            (lhs.positiveValues < rhs.positiveValues && lhs.negativeValues <= rhs.negativeValues)
            || (lhs.positiveValues <= rhs.positiveValues && lhs.negativeValues < rhs.negativeValues)
    }

    public static func <= (lhs: PNCounter<Actor>, rhs: PNCounter<Actor>) -> Bool {
        return lhs.positiveValues <= rhs.positiveValues
            && lhs.negativeValues <= rhs.negativeValues
    }
}

extension PNCounter: Equatable where Actor: Equatable {}

extension PNCounter: Hashable where Actor: Hashable {}

extension PNCounter: Codable where Actor: Codable {}

extension PNCounter.CRDTOperation: Equatable where Actor: Equatable {}

extension PNCounter.CRDTOperation: Hashable where Actor: Hashable {}

extension PNCounter.CRDTOperation: Codable where Actor: Codable {}

extension PNCounter: CmRDT {
    public mutating func apply(_ operation: CRDTOperation) {
        switch operation.direction {
        case .positive:
            self.positiveValues.apply(operation.counterOperation)
        case .negative:
            self.negativeValues.apply(operation.counterOperation)
        }
    }
}

extension PNCounter: CvRDT {
    public mutating func merge(_ other: PNCounter<Actor>) throws {
        try self.positiveValues.merge(other.positiveValues)
        try self.negativeValues.merge(other.negativeValues)
    }

    public func merged(_ other: Self) throws -> Self {
        var copy = self
        try copy.merge(other)
        return copy
    }
}
