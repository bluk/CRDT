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

import struct Foundation.UUID

import CRDT

public struct ActorLogicalClockTimestamp: Hashable, Codable, PartialOrderable {
    public typealias Actor = UUID
    public typealias Clock = UInt64

    public private(set) var timestamp: VClock<Actor, Clock>

    public init(actor: Actor) {
        self.timestamp = VClock<Actor, Clock>()
        self.timestamp.incrementClock(for: actor)
    }

    public init(timestamp: VClock<Actor, Clock>) {
        self.timestamp = timestamp
    }

    @discardableResult
    public mutating func increment(for actor: Actor) -> ActorClock<Actor, Clock> {
        return self.timestamp.incrementClock(for: actor)
    }

    public func makeIncrementedTimestamp(for actor: Actor) -> ActorLogicalClockTimestamp {
        var copy = self
        copy.timestamp.incrementClock(for: actor)
        return copy
    }

    public static func < (lhs: ActorLogicalClockTimestamp, rhs: ActorLogicalClockTimestamp) -> Bool {
        return lhs.timestamp < rhs.timestamp
    }

    public static func <= (lhs: ActorLogicalClockTimestamp, rhs: ActorLogicalClockTimestamp) -> Bool {
        return lhs.timestamp <= rhs.timestamp
    }
}

extension LWWRegister where Timestamp == ActorLogicalClockTimestamp {
    public init(value: Value, actor: ActorLogicalClockTimestamp.Actor) {
        self.init(value: value, timestamp: ActorLogicalClockTimestamp(actor: actor))
    }

    public mutating func assign(value: Value, for actor: ActorLogicalClockTimestamp.Actor) throws {
        try self.assign(value: value, timestamp: self.timestamp.makeIncrementedTimestamp(for: actor))
    }
}
