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

/// A last writer wins register. Stores a value with an associated timestamp.
public struct LWWRegister<Value: Equatable, Timestamp: PartialOrderable>: PartialOrderable {
    public enum Error: Swift.Error {
        /// Thrown if the registers have the same timestamp but have different values.
        case conflictingValuesForSameTimestamp
        /// Thrown if the registers have timestamps which are not comparable. Usually, it indicates that the registers cannot be merged due to diverging
        /// history.
        case uncomparableTimestamps
    }

    public typealias CRDTOperation = LWWRegister<Value, Timestamp>

    public private(set) var value: Value
    public private(set) var timestamp: Timestamp

    public init(value: Value, timestamp: Timestamp) {
        self.value = value
        self.timestamp = timestamp
    }

    public mutating func assign(value: Value, timestamp: Timestamp) throws {
        guard self.timestamp != timestamp else {
            if self.value != value {
                throw LWWRegister.Error.conflictingValuesForSameTimestamp
            }
            return
        }

        guard self.timestamp < timestamp else {
            if !(timestamp < self.timestamp) {
                throw LWWRegister.Error.uncomparableTimestamps
            }
            return
        }

        self.value = value
        self.timestamp = timestamp
    }

    public static func < (lhs: LWWRegister<Value, Timestamp>, rhs: LWWRegister<Value, Timestamp>) -> Bool {
        return lhs.timestamp < rhs.timestamp
    }

    public static func <= (lhs: LWWRegister<Value, Timestamp>, rhs: LWWRegister<Value, Timestamp>) -> Bool {
        return lhs.timestamp <= rhs.timestamp
    }

    public static func == (lhs: LWWRegister<Value, Timestamp>, rhs: LWWRegister<Value, Timestamp>) -> Bool {
        return lhs.timestamp == rhs.timestamp
    }
}

extension LWWRegister: Equatable where Value: Equatable, Timestamp: Equatable {}

extension LWWRegister: Hashable where Value: Hashable, Timestamp: Hashable {}

extension LWWRegister: Codable where Value: Codable, Timestamp: Codable {}

extension LWWRegister: CvRDT {
    public mutating func merge(_ other: LWWRegister<Value, Timestamp>) throws {
        try self.assign(value: other.value, timestamp: other.timestamp)
    }

    public func merged(_ other: LWWRegister<Value, Timestamp>) throws -> LWWRegister<Value, Timestamp> {
        var copy = self
        try copy.merge(other)
        return copy
    }
}

extension LWWRegister: CmRDT {
    public mutating func apply(_ operation: LWWRegister<Value, Timestamp>) throws {
        try self.merge(operation)
    }
}
