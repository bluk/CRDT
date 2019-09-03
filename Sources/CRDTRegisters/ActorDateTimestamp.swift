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

import struct Foundation.Date
import struct Foundation.UUID

import CRDT

public struct ActorDateTimestamp: Hashable, Comparable, Codable, PartialOrderable {
    public typealias Actor = UUID
    public typealias Clock = Date

    public private(set) var timestamp: ActorClock<Actor, Clock>

    public init(actor: Actor, date: Date = Date()) {
        self.timestamp = ActorClock<Actor, Clock>(actor: actor, clock: date)
    }

    @discardableResult
    public mutating func increment(for actor: Actor) -> ActorClock<Actor, Clock> {
        let nextClock = Date()
        self.timestamp = ActorClock<Actor, Clock>(actor: actor, clock: nextClock)
        return self.timestamp
    }

    public func makeIncrementedTimestamp(for actor: Actor) -> ActorDateTimestamp {
        var copy = self
        let nextClock = Date()
        copy.timestamp = ActorClock<Actor, Clock>(actor: actor, clock: nextClock)
        return copy
    }

    public static func < (lhs: ActorDateTimestamp, rhs: ActorDateTimestamp) -> Bool {
        return lhs.timestamp.clock < rhs.timestamp.clock
            || (lhs.timestamp.clock == rhs.timestamp.clock && lhs.timestamp.actor.uuidString < rhs.timestamp.actor.uuidString)
    }

    public static func <= (lhs: ActorDateTimestamp, rhs: ActorDateTimestamp) -> Bool {
        return lhs.timestamp.clock <= rhs.timestamp.clock
            || (lhs.timestamp.clock == rhs.timestamp.clock && lhs.timestamp.actor.uuidString <= rhs.timestamp.actor.uuidString)
    }
}

extension LWWRegister where Timestamp == ActorDateTimestamp {
    public init(value: Value, actor: ActorDateTimestamp.Actor) {
        self.init(value: value, timestamp: ActorDateTimestamp(actor: actor))
    }

    public mutating func assign(value: Value, for actor: ActorDateTimestamp.Actor) throws {
        try self.assign(value: value, timestamp: self.timestamp.makeIncrementedTimestamp(for: actor))
    }
}
