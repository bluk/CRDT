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

public struct LSEQIdentifier16Source16Clock64<Element>: LSEQ {
    public typealias PositionType = PositionIdentifier16Source16Clock64

    public typealias Element = Element

    public typealias Index = Int

    public struct ElementContainer: LSEQElementContainer {
        public let position: PositionType

        public let element: Element
    }

    public struct Iterator: IteratorProtocol {
        var storageIterator: Array<ElementContainer>.Iterator

        public mutating func next() -> Element? {
            return self.storageIterator.next()?.element
        }
    }

    public struct Operation: LSEQOperation {
        public let kind: Kind
        public let position: PositionType
        public let element: Element?

        // swiftlint:disable nesting

        public enum Kind: Int, Codable {
            case insert = 1
            case remove = 2
        }

        // swiftlint:enable nesting

        public init(
            kind: Kind,
            position: PositionType,
            element: Element?
        ) {
            self.kind = kind
            self.position = position
            self.element = element
        }
    }

    public let boundary: PositionType.Segment.Identifier = 10
    public let source: PositionType.Segment.Source
    public let startPosition: PositionType
    public let endPosition: PositionType

    public internal(set) var clock: PositionType.Clock

    public internal(set) var storage: [ElementContainer] = []

    public init(
        source: PositionType.Segment.Source,
        clock: PositionType.Clock
    ) {
        self.clock = clock
        self.source = source

        self.startPosition = PositionType(
            segments: [
                PositionType.Segment(
                    id: 0,
                    source: PositionType.Segment.Source.min
                ),
            ],
            clock: 0
        )

        self.endPosition = PositionType(
            segments: [
                PositionType.Segment(
                    id: PositionType.Segment.Identifier.max,
                    source: PositionType.Segment.Source.max
                ),
            ],
            clock: 0
        )
    }

    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        self.storage.reserveCapacity(minimumCapacity)
    }

    public mutating func insert(_ newElement: Element, at index: Index) {
        let newPosition = self.makeInsertPosition(at: index)
        self.storage.insert(ElementContainer(position: newPosition, element: newElement), at: index)
    }

    public mutating func insertAndMakeOperation(_ newElement: Element, at index: Index) -> Operation {
        let newPosition = self.makeInsertPosition(at: index)
        self.storage.insert(ElementContainer(position: newPosition, element: newElement), at: index)
        return Operation(kind: .insert, position: newPosition, element: newElement)
    }

    @discardableResult
    public mutating func remove(at index: Index) -> Element {
        return self.storage.remove(at: index).element
    }

    @discardableResult
    public mutating func removeAndMakeOperation(at index: Index) -> (Element, Operation) {
        let removedElement = self.storage.remove(at: index)

        return (removedElement.element, Operation(kind: .remove, position: removedElement.position, element: nil))
    }

    public mutating func apply(_ operation: Operation) {
        switch operation.kind {
        case .insert:
            guard let newElement = operation.element else {
                assertionFailure("Insert operation did not have element.")
                return
            }

            let insertPosition = operation.position

            let insertIndex = self.storage.insertionIndex { elementContainer -> Bool in
                elementContainer.position < insertPosition
            }

            if insertIndex < self.storage.endIndex {
                guard self.storage[insertIndex].position != insertPosition else {
                    return
                }
            }

            self.storage.insert(
                ElementContainer(position: insertPosition, element: newElement),
                at: insertIndex
            )

            return
        case .remove:
            let removePosition = operation.position
            let possibleExistingIndex = self.storage.insertionIndex { elementContainer -> Bool in
                elementContainer.position < removePosition
            }

            guard possibleExistingIndex < self.storage.endIndex else {
                return
            }

            guard self.storage[possibleExistingIndex].position == removePosition else {
                return
            }

            self.storage.remove(at: possibleExistingIndex)

            return
        }
    }

    public func makeDifferenceOperations(from other: LSEQIdentifier16Source16Clock64<Element>) -> [Operation] {
        // other is the base state
        var selfIterator = self.storage.makeIterator()
        var otherIterator = other.storage.makeIterator()

        var selfElementContainer = selfIterator.next()
        var otherElementContainer = otherIterator.next()

        var operations: [Operation] = []

        while let selfEC = selfElementContainer,
            let otherEC = otherElementContainer {
            if selfEC.position == otherEC.position {
                selfElementContainer = selfIterator.next()
                otherElementContainer = otherIterator.next()
            } else if selfEC.position < otherEC.position {
                operations.append(Operation(kind: .insert, position: selfEC.position, element: selfEC.element))
                selfElementContainer = selfIterator.next()
            } else {
                operations.append(Operation(kind: .remove, position: otherEC.position, element: nil))
                otherElementContainer = otherIterator.next()
            }
        }

        while let selfEC = selfElementContainer {
            operations.append(Operation(kind: .insert, position: selfEC.position, element: selfEC.element))

            selfElementContainer = selfIterator.next()
        }

        while let otherEC = otherElementContainer {
            operations.append(Operation(kind: .remove, position: otherEC.position, element: nil))

            otherElementContainer = otherIterator.next()
        }

        return operations
    }

    mutating func makeInsertPosition(at index: Int) -> PositionType {
        let pPosition: PositionType
        let qPosition: PositionType

        if index == 0 {
            pPosition = self.startPosition
            if self.storage.isEmpty {
                qPosition = self.endPosition
            } else {
                qPosition = self.storage[0].position
            }
        } else if index == self.storage.count {
            pPosition = self.storage[self.storage.count - 1].position
            qPosition = self.endPosition
        } else {
            pPosition = self.storage[index - 1].position
            qPosition = self.storage[index].position
        }

        assert(pPosition < qPosition, "\(pPosition) is not < \(qPosition)")

        let newPositionSegments = PositionType.allocateBetween(
            p: pPosition,
            q: qPosition,
            boundary: self.boundary,
            source: self.source
        )

        assert(
            pPosition < PositionType(segments: newPositionSegments, clock: clock),
            "\(pPosition) >= \(PositionType(segments: newPositionSegments, clock: clock))"
        )
        assert(
            PositionType(segments: newPositionSegments, clock: clock) < qPosition,
            "\(PositionType(segments: newPositionSegments, clock: clock)) >= \(qPosition)"
        )

        self.clock += 1

        var optimizedPositionSegments: [PositionType.Segment] = []
        optimizedPositionSegments.reserveCapacity(newPositionSegments.count)
        optimizedPositionSegments.append(contentsOf: newPositionSegments)
        return PositionType(segments: optimizedPositionSegments, clock: self.clock)
    }

    @inlinable public var count: Int { return storage.count }

    @inlinable public var isEmpty: Bool { return storage.isEmpty }

    @inlinable public var startIndex: Int { return storage.startIndex }

    @inlinable public var endIndex: Int { return storage.endIndex }

    @inlinable
    public subscript(index: Int) -> Element { return self.storage[index].element }

    @inlinable
    public func index(after index: Int) -> Int {
        return self.storage.index(after: index)
    }

    public func makeIterator() -> Iterator {
        return Iterator(storageIterator: self.storage.makeIterator())
    }
}

extension LSEQIdentifier16Source16Clock64.Operation: Equatable where Element: Equatable {}

extension LSEQIdentifier16Source16Clock64.Operation: Codable where Element: Codable {}

extension LSEQIdentifier16Source16Clock64.ElementContainer: Codable where Element: Codable {}

extension LSEQIdentifier16Source16Clock64.ElementContainer: Equatable where Element: Equatable {}

extension LSEQIdentifier16Source16Clock64: Codable where Element: Codable {}

extension LSEQIdentifier16Source16Clock64: Equatable where Element: Equatable {}
