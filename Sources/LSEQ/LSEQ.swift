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

public protocol LSEQ: Collection {
    associatedtype PositionType

    associatedtype Element

    associatedtype Index

    associatedtype ElementContainer where ElementContainer: LSEQElementContainer,
        ElementContainer.PositionType == PositionType, ElementContainer.Element == Element

    associatedtype Operation where Operation: LSEQOperation,
        Operation.PositionType == PositionType, Operation.Element == Element

    var boundary: PositionType.Segment.Identifier { get }
    var source: PositionType.Segment.Source { get }
    var startPosition: PositionType { get }
    var endPosition: PositionType { get }
    var clock: PositionType.Clock { get }
    var storage: [ElementContainer] { get }

    mutating func reserveCapacity(_ minimumCapacity: Int)

    mutating func insert(_ newElement: Element, at index: Index)

    mutating func insertAndMakeOperation(_ newElement: Element, at index: Index) -> Operation

    @discardableResult
    mutating func remove(at index: Index) -> Element

    @discardableResult
    mutating func removeAndMakeOperation(at index: Index) -> (Element, Operation)

    mutating func apply(_ operation: Operation)

    func makeDifferenceOperations(from other: Self) -> [Operation]
}

public protocol LSEQOperation {
    associatedtype Kind
    associatedtype PositionType where PositionType: Position
    associatedtype Element

    var kind: Kind { get }
    var position: PositionType { get }
    var element: Element? { get }
}

public protocol LSEQElementContainer {
    associatedtype PositionType where PositionType: Position
    associatedtype Element

    var position: PositionType { get }
    var element: Element { get }
}

internal extension RandomAccessCollection {
    func insertionIndex(for predicate: (Element) -> Bool) -> Index {
        var slice: SubSequence = self[...]

        while !slice.isEmpty {
            let middle = slice.index(slice.startIndex, offsetBy: slice.count / 2)
            if predicate(slice[middle]) {
                slice = slice[index(after: middle)...]
            } else {
                slice = slice[..<middle]
            }
        }
        return slice.startIndex
    }
}
