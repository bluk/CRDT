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

/// A multi-value register.
public struct MVRegister<Value: Equatable, Actor: Equatable, Clock: Comparable>: Equatable, PartialOrderable {
    public struct CRDTOperation: Equatable {
        // swiftlint:disable nesting

        public enum Kind: Int, Codable {
            case put = 1
        }

        // swiftlint:enable nesting

        public let kind: Kind
        public let vclock: VClock<Actor, Clock>
        public let value: Value

        public init(kind: Kind, vclock: VClock<Actor, Clock>, value: Value) {
            self.kind = kind
            self.vclock = vclock
            self.value = value
        }
    }

    public enum Error: Swift.Error {
        /// Thrown if the register has a conflicting value for the same vector clock.
        case conflictingValuesForSameVClock
    }

    public struct RegisterValue: Equatable {
        let value: Value
        let vclock: VClock<Actor, Clock>
    }

    public struct ReadContext: Equatable {
        public let addVClock: VClock<Actor, Clock>
        public let values: [Value]

        public init(addVClock: VClock<Actor, Clock>, values: [Value]) {
            self.addVClock = addVClock
            self.values = values
        }
    }

    var values: [RegisterValue] = []
    let clockZeroValue: Clock

    public init(clockZeroValue: Clock) {
        self.clockZeroValue = clockZeroValue
    }

    func makeClock() throws -> VClock<Actor, Clock> {
        return try self.values.reduce(into: VClock<Actor, Clock>(clockZeroValue: clockZeroValue)) { result, value in
            try result.merge(value.vclock)
        }
    }

    public func makeReadContext() throws -> ReadContext {
        let vclock: VClock<Actor, Clock> = try makeClock()
        let concurrentValues: [Value] = self.values.reduce(into: [], { result, value in
            guard !result.contains(value.value) else {
                return
            }

            result.append(value.value)
        })

        return ReadContext(addVClock: vclock, values: concurrentValues)
    }

    public static func < (lhs: MVRegister<Value, Actor, Clock>, rhs: MVRegister<Value, Actor, Clock>) -> Bool {
        for lhsValue in lhs.values {
            guard rhs.values.contains(where: { lhsValue.vclock < $0.vclock }) else {
                return false
            }
        }

        return true
    }

    public static func <= (lhs: MVRegister<Value, Actor, Clock>, rhs: MVRegister<Value, Actor, Clock>) -> Bool {
        return lhs < rhs || lhs == rhs
    }

    public static func == (lhs: MVRegister<Value, Actor, Clock>, rhs: MVRegister<Value, Actor, Clock>) -> Bool {
        for lhsValue in lhs.values {
            let foundCount = rhs.values.filter { rhsValue -> Bool in
                lhsValue == rhsValue
            }.count

            guard foundCount > 0 else {
                return false
            }

            assert(foundCount == 1, "Found \(foundCount) values for \(lhsValue.value)")
        }

        for rhsValue in rhs.values {
            let foundCount = lhs.values.filter { lhsValue -> Bool in
                lhsValue == rhsValue
            }.count

            guard foundCount > 0 else {
                return false
            }

            assert(foundCount == 1, "Found \(foundCount) values for \(rhsValue.value)")
        }

        return true
    }
}

/// Convenience methods when the Clock is a BinaryInteger.
public extension MVRegister where Clock: BinaryInteger {
    /// Initializes with a clock zero value to 0.
    init() {
        self.init(clockZeroValue: 0)
    }

    /// Assigns a value for an actor by making a put operation and applying it.
    ///
    /// - Parameter value: The value to add
    /// - Parameter actor: The actor which is adding the value
    /// - Returns: The put operation which has already been applied
    @discardableResult
    mutating func put(value: Value, for actor: Actor) throws -> CRDTOperation {
        let operation = try self.makeReadContext().makePutOperation(value: value, for: actor)
        try self.apply(operation)
        return operation
    }
}

/// Convenience methods when the Clock is a BinaryInteger.
public extension MVRegister.ReadContext where Clock: BinaryInteger {
    /// Makes a CRDTOperation which puts a value into the register if applied.
    ///
    /// - Parameter value: The value to add
    /// - Parameter actor: The actor which is adding the value
    /// - Returns: The put operation
    func makePutOperation(value: Value, for actor: Actor) -> MVRegister.CRDTOperation {
        var vclock = self.addVClock
        vclock.incrementClock(for: actor)
        return MVRegister.CRDTOperation(kind: .put, vclock: vclock, value: value)
    }
}

extension MVRegister.ReadContext: Hashable where Value: Hashable, Actor: Hashable, Clock: Hashable {}

extension MVRegister.ReadContext: Codable where Value: Codable, Actor: Codable, Clock: Codable {}

extension MVRegister.CRDTOperation: Hashable where Value: Hashable, Actor: Hashable, Clock: Hashable {}

extension MVRegister.CRDTOperation: Codable where Value: Codable, Actor: Codable, Clock: Codable {}

extension MVRegister.RegisterValue: Hashable where Value: Hashable, Actor: Hashable, Clock: Hashable {}

extension MVRegister.RegisterValue: Codable where Value: Codable, Actor: Codable, Clock: Codable {}

extension MVRegister: Hashable where Value: Hashable, Actor: Hashable, Clock: Hashable {}

extension MVRegister: Codable where Value: Codable, Actor: Codable, Clock: Codable {}

extension MVRegister: CvRDT {
    public mutating func merge(_ other: MVRegister<Value, Actor, Clock>) throws {
        var keptSelfValues = self.values.filter { value in
            let selfVClock = value.vclock
            return !other.values.contains { selfVClock < $0.vclock }
        }

        let keptOtherValues = other.values
            .filter { value in
                let otherVClock = value.vclock
                return !keptSelfValues.contains { otherVClock < $0.vclock }
            }
            .filter { value in
                !keptSelfValues.contains { value.vclock == $0.vclock }
            }

        keptSelfValues.append(contentsOf: keptOtherValues)
        self.values = keptSelfValues
    }

    /// An idempotent and commutative function which attempts to produce a new instance with the
    /// other instance's state merged with this instance's state.
    ///
    /// - Parameter other: The other instance
    /// - Throws: Throws an error if the states could not be merged.
    /// - Returns: A new instance which is the result of merging this instance's state with the
    ///            other instance's state.
    public func merged(_ other: MVRegister<Value, Actor, Clock>) throws -> MVRegister<Value, Actor, Clock> {
        var copy = self
        try copy.merge(other)
        return copy
    }
}

extension MVRegister: CmRDT {
    public mutating func apply(_ operation: CRDTOperation) throws {
        switch operation.kind {
        case .put:
            guard !operation.vclock.allClocksAtZeroValue else {
                return
            }

            let operationVClock = operation.vclock

            let shouldAdd = !self.values.contains { operationVClock < $0.vclock }
            guard shouldAdd else {
                return
            }

            let operationValue = operation.value

            self.values = try self.values.filter { value in
                guard value.vclock != operationVClock else {
                    if value.value != operationValue {
                        throw Error.conflictingValuesForSameVClock
                    }
                    return false
                }
                return !(value.vclock < operationVClock)
            }
            self.values.append(RegisterValue(value: operationValue, vclock: operationVClock))
        }
    }
}
