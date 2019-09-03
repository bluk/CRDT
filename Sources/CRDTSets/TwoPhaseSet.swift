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

/// A 2-phase set where elements can be inserted but after an element is removed, the element cannot be inserted again.
public struct TwoPhaseSet<Element: Hashable>: PartialOrderable, Hashable {
    /// The elements in the set.
    public private(set) var elements: Set<Element> = []
    /// The elements which have been removed from the set.
    public private(set) var removedElements: Set<Element> = []

    /// Initializes the set with existing elements and elements which have already been removed.
    ///
    /// - Parameter elements: The existing elements in the set
    /// - Parameter removedElements: The elements which have already been removed from the set
    public init(elements: Set<Element> = [], removedElements: Set<Element> = []) {
        self.elements = elements
        self.removedElements = removedElements
        assert(self.elements.intersection(self.removedElements) == [])
    }

    /// Insert a value into the set.
    ///
    /// - Parameter newMember: The new element
    /// - Returns: A tuple which returns true if the element was inserted and false otherwise, and the element
    ///            after being inserted.
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        guard !self.removedElements.contains(newMember) else {
            return (false, newMember)
        }

        return self.elements.insert(newMember)
    }

    /// Removes a value from the set.
    ///
    /// - Parameter member: The element to remove
    /// - Returns: The element which was removed
    public mutating func remove(_ member: Element) -> Element? {
        guard let removedElement = self.elements.remove(member) else {
            return nil
        }

        self.removedElements.insert(member)
        return removedElement
    }

    public static func < (lhs: TwoPhaseSet<Element>, rhs: TwoPhaseSet<Element>) -> Bool {
        return
            (
                lhs.elements.isStrictSubset(of: rhs.elements)
                    && lhs.removedElements.isSubset(of: rhs.removedElements)
            )
            ||
            (
                lhs.elements.isSubset(of: rhs.elements)
                    && lhs.removedElements.isStrictSubset(of: rhs.removedElements)
            )
    }

    public static func <= (lhs: TwoPhaseSet<Element>, rhs: TwoPhaseSet<Element>) -> Bool {
        return lhs.elements.isSubset(of: rhs.elements)
            && lhs.removedElements.isSubset(of: rhs.removedElements)
    }
}

extension TwoPhaseSet: Codable where Element: Codable {}

extension TwoPhaseSet: CvRDT {
    public mutating func merge(_ other: TwoPhaseSet<Element>) throws {
        self.elements = self.elements.filter { !other.removedElements.contains($0) }
        self.elements.formUnion(other.elements.filter { !self.removedElements.contains($0) })
        self.removedElements.formUnion(other.removedElements)
    }

    public func merged(_ other: TwoPhaseSet<Element>) throws -> TwoPhaseSet<Element> {
        var copy = self
        try copy.merge(other)
        return copy
    }
}

extension TwoPhaseSet: CmRDT {
    public struct CRDTOperation {
        public enum Kind: Int8, Codable {
            case insert = 1
            case remove = 2
        }

        public let kind: Kind
        public let element: Element
    }

    public func makeInsertionOperation(for element: Element) -> CRDTOperation? {
        return CRDTOperation(kind: .insert, element: element)
    }

    public func makeRemovalOperation(for element: Element) -> CRDTOperation? {
        guard self.elements.contains(element) else {
            return nil
        }

        return CRDTOperation(kind: .remove, element: element)
    }

    public mutating func apply(_ operation: CRDTOperation) throws {
        switch operation.kind {
        case .insert:
            _ = self.insert(operation.element)
        case .remove:
            _ = self.remove(operation.element)
            self.removedElements.insert(operation.element)
        }
    }
}
