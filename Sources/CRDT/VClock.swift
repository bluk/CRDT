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

/// A vector clock which stores clocks for processes. Each process participating in a system has its own clock.
/// When an event occurs in a process, the process should increment its own clock.
public struct VClock<Process: Equatable, Clock: Comparable>: PartialOrderable {
    public struct ProcessClock {
        public let process: Process
        public let clock: Clock

        public init(process: Process, clock: Clock) {
            self.process = process
            self.clock = clock
        }
    }

    public enum Error: Swift.Error {
        case conflictingClockZeroValue
    }

    public typealias CRDTOperation = ProcessClock

    /// The vector clock's value
    public private(set) var nonzeroClockValues: [ProcessClock]
    public private(set) var clockZeroValue: Clock

    /// - Parameter clockZeroValue: The clock's zero value. The zero value is the initial value of a clock in a
    ///                             process where no event has occurred.
    public init(clockZeroValue: Clock) {
        self.clockZeroValue = clockZeroValue
        self.nonzeroClockValues = []
    }

    /// - Parameter process: The process
    /// - Returns: The process's clock value
    public subscript(index: Process) -> Clock {
        return self.nonzeroClockValues.first(where: { $0.process == index })?.clock
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
    public func isConcurrentTo(_ other: VClock<Process, Clock>) -> Bool {
        return !(self <= other) && !(other <= self)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.nonzeroClockValues.allSatisfy { processClock -> Bool in
            let rhsClockValue = rhs[processClock.process]
            return processClock.clock < rhsClockValue
        }
            && ((lhs.clockZeroValue < rhs.clockZeroValue) ||
                ((lhs.clockZeroValue == rhs.clockZeroValue) && !rhs.allClocksAtZeroValue))
    }

    public static func <= (lhs: Self, rhs: Self) -> Bool {
        return lhs.nonzeroClockValues.allSatisfy { processClock -> Bool in
            let rhsClockValue = rhs[processClock.process]
            return processClock.clock <= rhsClockValue
        }
            && (lhs.clockZeroValue <= rhs.clockZeroValue)
    }

    /// Forms the greatest lower bound value given this instance's clocks and the other instance's clocks.
    ///
    /// - Parameter other: The other instance
    public mutating func formGreatestLowerBound(_ other: VClock<Process, Clock>) {
        if self.clockZeroValue <= other.clockZeroValue {
            for (index, processClock) in self.nonzeroClockValues.enumerated() {
                let otherClockValue = other[processClock.process]
                if otherClockValue < processClock.clock {
                    self.nonzeroClockValues[index] = ProcessClock(process: processClock.process, clock: otherClockValue)
                }
            }
        } else if other.clockZeroValue < self.clockZeroValue {
            var nonzeroClockValuesCopy: [ProcessClock] = other.nonzeroClockValues
            for (index, processClock) in nonzeroClockValuesCopy.enumerated() {
                let selfClockValue = self[processClock.process]
                if selfClockValue < processClock.clock {
                    nonzeroClockValuesCopy[index] = ProcessClock(process: processClock.process, clock: selfClockValue)
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
    public func greatestLowerBound(_ other: VClock<Process, Clock>) -> Self {
        var copy = self
        copy.formGreatestLowerBound(other)
        return copy
    }

    /// Removes clock data from this instance's for values where the other clock's data is ahead.
    ///
    /// - Parameter other: The other instance
    public mutating func forget(_ other: VClock<Process, Clock>) {
        for processClock in other.nonzeroClockValues {
            let value = self[processClock.process]
            if value < processClock.clock {
                self.nonzeroClockValues.removeAll(where: { $0.process == processClock.process })
            }
        }
        self.checkInvariants()
    }

    /// Forms an intersection between this instance's clock values and the other instance's clock values.
    ///
    /// - Throws: Throws an error if this instance's clock zero value and the other instance's clock zero
    ///           value are not equal.
    public mutating func formIntersection(_ other: VClock<Process, Clock>) throws {
        if self.clockZeroValue != other.clockZeroValue {
            throw Error.conflictingClockZeroValue
        }

        var processClockValues: [ProcessClock] = []
        processClockValues.reserveCapacity(self.nonzeroClockValues.count)
        for processClock in self.nonzeroClockValues {
            let otherValue = other[processClock.process]
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
    public func intersection(_ other: VClock<Process, Clock>) throws -> Self {
        var copy = self
        try copy.formIntersection(other)
        return copy
    }

    private func checkInvariants() {
        assert({
            let processes = self.nonzeroClockValues.map { $0.process }
            let reducedProcesses = processes.reduce([]) { partialResult, process -> [Process] in
                if partialResult.contains(process) {
                    return partialResult
                }
                return partialResult + [process]
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

    /// Makes an operation which increments a clock for a process.
    ///
    /// - Parameter process: The process which clock to increment
    /// - Returns: An operation which increments a clock for a process.
    func makeIncrementClockOperation(for process: Process) -> ProcessClock {
        let next = self[process] + 1
        return ProcessClock(process: process, clock: next)
    }

    /// Makes an operation which increments a clock for a process and applies
    /// the operation to increment the value.
    ///
    /// - Parameter process: The process which clock to increment
    /// - Returns: An operation which increments a clock for a process.
    @discardableResult
    mutating func incrementClock(for process: Process) -> ProcessClock {
        let processClock = self.makeIncrementClockOperation(for: process)
        self.apply(processClock)
        return processClock
    }
}

extension VClock: Equatable where Process: Equatable, Clock: Equatable {}

extension VClock: Hashable where Process: Hashable, Clock: Hashable {}

extension VClock: Codable where Process: Codable, Clock: Codable {}

extension VClock.ProcessClock: Equatable where Process: Equatable, Clock: Equatable {}

extension VClock.ProcessClock: Hashable where Process: Hashable, Clock: Hashable {}

extension VClock.ProcessClock: Codable where Process: Codable, Clock: Codable {}

extension VClock: CmRDT {
    public mutating func apply(_ operation: VClock.ProcessClock) {
        guard self.clockZeroValue < operation.clock else {
            return
        }
        guard let processIndex = self.nonzeroClockValues.firstIndex(where: { $0.process == operation.process }) else {
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
    public mutating func merge(_ other: VClock<Process, Clock>) throws {
        if self.clockZeroValue != other.clockZeroValue {
            throw Error.conflictingClockZeroValue
        }

        for processClock in other.nonzeroClockValues {
            self.apply(processClock)
        }
    }

    public func merged(_ other: Self) throws -> Self {
        var copy = self
        try copy.merge(other)
        return copy
    }
}
