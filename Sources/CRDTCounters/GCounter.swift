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

/// A grow-only counter. Increasing values from each actor can be generated and applied.
public struct GCounter<Actor: Equatable>: PartialOrderable {
    public struct CRDTOperation {
        public let value: ActorClock<Actor, Value>
    }

    public typealias Value = UInt64

    var actorCounters: VClock<Actor, Value>

    public init() {
        self.actorCounters = VClock<Actor, Value>(clockZeroValue: 0)
    }

    public var value: Value {
        return self.actorCounters.nonzeroClockValues.reduce(0) { partialResult, actorClock -> Value in
            partialResult + actorClock.clock
        }
    }

    public func makeIncrementCounterOperation(for actor: Actor) -> CRDTOperation {
        return CRDTOperation(value: actorCounters.makeIncrementClockOperation(for: actor))
    }

    @discardableResult
    public mutating func incrementCounter(for actor: Actor) -> CRDTOperation {
        let operation = self.makeIncrementCounterOperation(for: actor)
        self.apply(operation)
        return operation
    }

    public static func < (lhs: GCounter<Actor>, rhs: GCounter<Actor>) -> Bool {
        return lhs.actorCounters < rhs.actorCounters
    }

    public static func <= (lhs: GCounter<Actor>, rhs: GCounter<Actor>) -> Bool {
        return lhs.actorCounters <= rhs.actorCounters
    }
}

extension GCounter: Equatable where Actor: Equatable {}

extension GCounter: Hashable where Actor: Hashable {}

extension GCounter: Codable where Actor: Codable {}

extension GCounter.CRDTOperation: Equatable where Actor: Equatable {}

extension GCounter.CRDTOperation: Hashable where Actor: Hashable {}

extension GCounter.CRDTOperation: Codable where Actor: Codable {}

extension GCounter: CmRDT {
    public mutating func apply(_ operation: CRDTOperation) {
        self.actorCounters.apply(operation.value)
    }
}

extension GCounter: CvRDT {
    public mutating func merge(_ other: GCounter<Actor>) throws {
        try self.actorCounters.merge(other.actorCounters)
    }

    public func merged(_ other: GCounter<Actor>) throws -> GCounter<Actor> {
        var copy = self
        try copy.merge(other)
        return copy
    }
}
