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

/// Represents an actor in a system and a relative clock value. An actor could be
/// a process, a device, a person, or other entity. A clock value can be
/// any ordered value such as a logical clock or a date time.
public struct ActorClock<Actor: Equatable, Clock: Comparable> {
    /// An actor in a system.
    public let actor: Actor
    /// An actor's clock value
    public let clock: Clock

    /// Initializes the struct with the given values.
    public init(actor: Actor, clock: Clock) {
        self.actor = actor
        self.clock = clock
    }
}

extension ActorClock: Equatable where Actor: Equatable, Clock: Equatable {}

extension ActorClock: Hashable where Actor: Hashable, Clock: Hashable {}

extension ActorClock: Codable where Actor: Codable, Clock: Codable {}
