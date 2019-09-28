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

/// A vector clock which stores clocks for actors in a system. Each actor participating in a system has its own clock.
/// An actor could represent a process, a device, a person, or other entity. When an event occurs in an actor, the
/// actor should increment its own clock.
public struct VClock<Actor: Equatable, Clock: Comparable>: PartialOrderable {
    public enum Error: Swift.Error {
        case conflictingClockZeroValue
    }

    public typealias CRDTOperation = ActorClock

    /// The vector clock's value
    public private(set) var nonzeroClockValues: [ActorClock<Actor, Clock>]
    public private(set) var clockZeroValue: Clock

    /// - Parameter clockZeroValue: The clock's zero value. The zero value is the initial value of a clock in an
    ///                             actor where no event has occurred.
    public init(clockZeroValue: Clock) {
        self.clockZeroValue = clockZeroValue
        self.nonzeroClockValues = []
    }

    /// - Parameter index: The actor
    /// - Returns: The actor's clock value
    public subscript(index: Actor) -> Clock {
        return self.nonzeroClockValues.first(where: { $0.actor == index })?.clock
            ?? self.clockZeroValue
    }

    /// - Returns: true if all processes are at the zero clock value, false otherwise.
    public var allClocksAtZeroValue: Bool {
        return self.nonzeroClockValues.isEmpty
    }

    /// Determines if the two vector clocks have clock values which are not orderable.
    ///
    /// - Returns: true if this instance and the other instance do not indicate a less than or equal orderable
    ///            relationship between the respective clock values.
    public func isConcurrentTo(_ other: VClock<Actor, Clock>) -> Bool {
        return !(self <= other) && !(other <= self)
    }

    public static func < (lhs: VClock<Actor, Clock>, rhs: VClock<Actor, Clock>) -> Bool {
        guard lhs.clockZeroValue <= rhs.clockZeroValue else {
            return false
        }

        guard !lhs.nonzeroClockValues.isEmpty else {
            return !rhs.nonzeroClockValues.isEmpty
        }

        let valuesCanBeLessThanOrEqual = (lhs.clockZeroValue < rhs.clockZeroValue)
            || (lhs.nonzeroClockValues.count < rhs.nonzeroClockValues.count)

        if valuesCanBeLessThanOrEqual {
            let isLessThanOrEqual = lhs.nonzeroClockValues.allSatisfy { processClock -> Bool in
                let rhsClockValue = rhs[processClock.actor]
                return processClock.clock <= rhsClockValue
            }

            if isLessThanOrEqual {
                return true
            }
        } else {
            let isStrictlyLessThan = lhs.nonzeroClockValues.allSatisfy { processClock -> Bool in
                let rhsClockValue = rhs[processClock.actor]
                return processClock.clock < rhsClockValue
            }

            if isStrictlyLessThan {
                return true
            }
        }

        return false
    }

    public static func <= (lhs: VClock<Actor, Clock>, rhs: VClock<Actor, Clock>) -> Bool {
        guard lhs.clockZeroValue <= rhs.clockZeroValue else {
            return false
        }

        let isLessThanOrEqual = lhs.nonzeroClockValues.allSatisfy { processClock -> Bool in
            let rhsClockValue = rhs[processClock.actor]
            return processClock.clock <= rhsClockValue
        }

        return isLessThanOrEqual
    }

    /// Forms the greatest lower bound value given this instance's clocks and the other instance's clocks.
    ///
    /// - Parameter other: The other instance
    public mutating func formGreatestLowerBound(_ other: VClock<Actor, Clock>) {
        if self.clockZeroValue <= other.clockZeroValue {
            for (index, processClock) in self.nonzeroClockValues.enumerated() {
                let otherClockValue = other[processClock.actor]
                if otherClockValue < processClock.clock {
                    self.nonzeroClockValues[index] = ActorClock(actor: processClock.actor, clock: otherClockValue)
                }
            }
        } else if other.clockZeroValue < self.clockZeroValue {
            var nonzeroClockValuesCopy: [ActorClock] = other.nonzeroClockValues
            for (index, processClock) in nonzeroClockValuesCopy.enumerated() {
                let selfClockValue = self[processClock.actor]
                if selfClockValue < processClock.clock {
                    nonzeroClockValuesCopy[index] = ActorClock(actor: processClock.actor, clock: selfClockValue)
                }
            }

            self.clockZeroValue = other.clockZeroValue
            self.nonzeroClockValues = nonzeroClockValuesCopy
        }

        self.nonzeroClockValues.removeAll(where: { $0.clock == self.clockZeroValue })

        self.checkInvariants()
    }

    /// Makes a greatest lower bound value given this instance's clocks and the other instance's clocks.
    ///
    /// - Parameter other: The other instance
    /// - Returns: A value which is the greatest lower bound of this instance's clocks and the other instance's clocks.
    public func greatestLowerBound(_ other: VClock<Actor, Clock>) -> VClock<Actor, Clock> {
        var copy = self
        copy.formGreatestLowerBound(other)
        return copy
    }

    /// Removes clock data from this instance's for values where the other clock's data is ahead.
    ///
    /// - Parameter other: The other instance
    public mutating func forget(_ other: VClock<Actor, Clock>) {
        for processClock in other.nonzeroClockValues {
            let value = self[processClock.actor]
            if value < processClock.clock {
                self.nonzeroClockValues.removeAll(where: { $0.actor == processClock.actor })
            }
        }
        self.checkInvariants()
    }

    /// Forms an intersection between this instance's clock values and the other instance's clock values.
    ///
    /// - Throws: Throws an error if this instance's clock zero value and the other instance's clock zero
    ///           value are not equal.
    public mutating func formIntersection(_ other: VClock<Actor, Clock>) throws {
        if self.clockZeroValue != other.clockZeroValue {
            throw Error.conflictingClockZeroValue
        }

        var processClockValues: [ActorClock<Actor, Clock>] = []
        processClockValues.reserveCapacity(self.nonzeroClockValues.count)
        for processClock in self.nonzeroClockValues {
            let otherValue = other[processClock.actor]
            if processClock.clock == otherValue {
                processClockValues.append(processClock)
            }
        }
        self.nonzeroClockValues = processClockValues
        self.checkInvariants()
    }

    /// Intersects between this instance's clock values and the other instance's clock values.
    ///
    /// - Throws: Throws an error if this instance's clock zero value and the other instance's clock zero value
    ///           are not equal.
    /// - Returns: The intersection of the clock values between this instance and the other instance.
    public func intersection(_ other: VClock<Actor, Clock>) throws -> VClock<Actor, Clock> {
        var copy = self
        try copy.formIntersection(other)
        return copy
    }

    private func checkInvariants() {
        assert({
            let processes = self.nonzeroClockValues.map { $0.actor }
            let reducedProcesses = processes.reduce([]) { partialResult, actor -> [Actor] in
                if partialResult.contains(actor) {
                    return partialResult
                }
                return partialResult + [actor]
            }
            if processes.count != reducedProcesses.count {
                return false
            }

            if !(self.nonzeroClockValues.allSatisfy { $0.clock > self.clockZeroValue }) {
                return false
            }

            return true
        }())
    }
}

/// Default implementation when the Clock value is a BinaryInteger.
public extension VClock where Clock: BinaryInteger {
    /// Initializes a VClock where the Clock values are types which conform to BinaryInteger and
    /// sets the clock zero value to 0.
    init() {
        self.init(clockZeroValue: 0)
    }

    /// Makes an operation which increments a clock for an actor.
    ///
    /// - Parameter actor: The actor whose clock to increment
    /// - Returns: An operation which increments a clock for an actor.
    func makeIncrementClockOperation(for actor: Actor) -> ActorClock<Actor, Clock> {
        let next = self[actor] + 1
        return ActorClock(actor: actor, clock: next)
    }

    /// Makes an operation which increments a clock for an actor and applies
    /// the operation to increment the value.
    ///
    /// - Parameter actor: The actor whose clock to increment
    /// - Returns: An operation which increments a clock for an actor.
    @discardableResult
    mutating func incrementClock(for actor: Actor) -> ActorClock<Actor, Clock> {
        let actorClock = self.makeIncrementClockOperation(for: actor)
        self.apply(actorClock)
        return actorClock
    }
}

extension VClock: Equatable where Actor: Equatable, Clock: Equatable {}

extension VClock: Hashable where Actor: Hashable, Clock: Hashable {}

extension VClock: Codable where Actor: Codable, Clock: Codable {}

extension VClock: CmRDT {
    public mutating func apply(_ operation: ActorClock<Actor, Clock>) {
        guard self.clockZeroValue < operation.clock else {
            return
        }
        guard let processIndex = self.nonzeroClockValues.firstIndex(where: { $0.actor == operation.actor }) else {
            self.nonzeroClockValues.append(operation)
            return
        }
        let existingClockValue = self.nonzeroClockValues[processIndex].clock
        if existingClockValue < operation.clock {
            self.nonzeroClockValues[processIndex] = operation
        }
        self.checkInvariants()
    }
}

extension VClock: CvRDT {
    public mutating func merge(_ other: VClock<Actor, Clock>) throws {
        if self.clockZeroValue != other.clockZeroValue {
            throw Error.conflictingClockZeroValue
        }

        for processClock in other.nonzeroClockValues {
            self.apply(processClock)
        }
    }

    /// An idempotent and commutative function which attempts to produce a new instance with the
    /// other instance's state merged with this instance's state.
    ///
    /// - Parameter other: The other instance
    /// - Throws: Throws an error if the states could not be merged.
    /// - Returns: A new instance which is the result of merging this instance's state with the
    ///            other instance's state.
    public func merged(_ other: VClock<Actor, Clock>) throws -> VClock<Actor, Clock> {
        var copy = self
        try copy.merge(other)
        return copy
    }
}
