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

/// A grow-only set.
public struct GSet<Element: Hashable>: PartialOrderable, Hashable {
    /// The elements in the set.
    public private(set) var elements: Set<Element>

    /// Initializes the set with a possible initial value.
    ///
    /// - Parameter initialValue: The initial value of the set. Defaults to an empty set.
    public init(_ initialValue: Set<Element> = []) {
        self.elements = initialValue
    }

    /// Insert a value into the set.
    ///
    /// - Parameter newMember: The new element
    /// - Returns: A tuple which returns true if the element was inserted and false otherwise, and the element
    ///            after being inserted.
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        return self.elements.insert(newMember)
    }

    /// Returns a union of this set's elements and the other set's elements.
    ///
    /// - Parameter other: The other set to form a union with.
    /// - Returns: A set which is the union of this instance's set and the other set.
    public mutating func union(_ other: GSet<Element>) -> GSet<Element> {
        return GSet(self.elements.union(other.elements))
    }

    /// Forms a union with the other set's elements.
    ///
    /// - Parameter other: The other set to form a union with.
    public mutating func formUnion(_ other: GSet<Element>) {
        self.elements.formUnion(other.elements)
    }

    public static func < (lhs: GSet<Element>, rhs: GSet<Element>) -> Bool {
        return lhs.elements.isStrictSubset(of: rhs.elements)
    }

    public static func <= (lhs: GSet<Element>, rhs: GSet<Element>) -> Bool {
        return lhs.elements.isSubset(of: rhs.elements)
    }
}

extension GSet: Codable where Element: Codable {}

extension GSet: CvRDT {
    public mutating func merge(_ other: GSet<Element>) throws {
        self.formUnion(other)
    }

    public func merged(_ other: GSet<Element>) throws -> GSet<Element> {
        var copy = self
        try copy.merge(other)
        return copy
    }
}

extension GSet: CmRDT {
    public mutating func apply(_ operation: Element) throws {
        self.elements.insert(operation)
    }
}
