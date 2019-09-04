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

public struct PositionIdentifier32Source16Clock64: Position, Codable {
    public typealias Clock = UInt64

    public struct Segment: PositionSegment, Codable {
        public typealias Identifier = UInt32
        public typealias Source = UInt16

        /// The relative position at a depth level in the sequence
        public let id: Identifier

        /// The source which created the segment
        public let source: Source

        public init(
            id: Identifier,
            source: Source
        ) {
            self.id = id
            self.source = source
        }
    }

    public let segments: [Segment]

    public let clock: Clock

    public init(
        segments: [Segment],
        clock: Clock
    ) {
        self.segments = segments
        self.clock = clock
    }
}
