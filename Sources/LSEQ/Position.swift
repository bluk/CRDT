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

/// Position is an element's relative location in the sequence.
public protocol Position: Comparable {
    associatedtype Clock where Clock: Comparable & FixedWidthInteger & BinaryInteger

    associatedtype Segment where Segment: PositionSegment

    var segments: [Segment] { get }

    var clock: Clock { get }

    init(segments: [Segment], clock: Clock)

    static func allocateBetween(
        p: Self,
        q: Self,
        boundary: Segment.Identifier,
        source: Segment.Source
    ) -> [Segment]
}

extension Position {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        let lhsCount = lhs.segments.count
        let rhsCount = rhs.segments.count
        let minCount = min(lhsCount, rhsCount)

        for index in 0..<minCount {
            let lhsSegment = lhs.segments[index]
            let rhsSegment = rhs.segments[index]

            if lhsSegment < rhsSegment {
                return true
            } else if lhsSegment == rhsSegment {
                continue
            } else {
                return false
            }
        }

        if lhsCount == rhsCount {
            return lhs.clock < rhs.clock
        } else if lhsCount < rhsCount {
            return true
        }

        return false
    }

    @inlinable
    public static func allocateBetween(
        p: Self,
        q: Self,
        boundary: Segment.Identifier,
        source: Segment.Source
    ) -> [Segment] {
        assert(p < q, "\(p) is not < \(q)")

        var pSegmentIterator = p.segments.makeIterator()
        var qSegmentIterator = q.segments.makeIterator()

        var newPositionSegments: [Segment] = []
        newPositionSegments.reserveCapacity(max(p.segments.count, q.segments.count) + 1)

        var isBoundaryPlus = true

        var possiblePSegment: Segment? = pSegmentIterator.next()
        var possibleQSegment: Segment? = qSegmentIterator.next()

        while let pSegment = possiblePSegment, let qSegment = possibleQSegment, pSegment.id == qSegment.id {
            newPositionSegments.append(pSegment)

            possiblePSegment = pSegmentIterator.next()
            possibleQSegment = qSegmentIterator.next()
            isBoundaryPlus = !isBoundaryPlus
        }

        var interval: Segment.Identifier = 0
        var stillNeedToCheckQ: Bool = true

        // Handle the first difference
        switch (possiblePSegment, possibleQSegment) {
        case let (.some(pSegment), .some(qSegment)):
            interval = qSegment.id - pSegment.id
            if isBoundaryPlus || interval <= 1 {
                newPositionSegments.append(pSegment)
            } else {
                newPositionSegments.append(qSegment)
            }

            stillNeedToCheckQ = false
        case let (.some(pSegment), .none):
            interval = Segment.Identifier.max - pSegment.id

            if interval == 0 {
                newPositionSegments.append(pSegment)
            } else {
                if isBoundaryPlus {
                    newPositionSegments.append(pSegment)
                } else {
                    newPositionSegments.append(
                        Segment(id: Segment.Identifier.max, source: source)
                    )
                }
            }

            stillNeedToCheckQ = false
        case let (.none, .some(qSegment)):
            interval = qSegment.id - Segment.Identifier.min

            if interval == 0 {
                newPositionSegments.append(qSegment)
            } else {
                if isBoundaryPlus || interval == 1 {
                    newPositionSegments.append(
                        Segment(id: Segment.Identifier.min, source: source)
                    )
                } else {
                    newPositionSegments.append(qSegment)
                }
            }

            if interval > 0 {
                stillNeedToCheckQ = false
            }
        case (.none, .none):
            let pickedPosition: Segment.Identifier

            if isBoundaryPlus {
                pickedPosition = Segment.Identifier.min
                interval = Segment.Identifier.max
            } else {
                pickedPosition = Segment.Identifier.max
                interval = Segment.Identifier.max
            }
            newPositionSegments.append(
                Segment(id: pickedPosition, source: source)
            )

            stillNeedToCheckQ = false
        }

        isBoundaryPlus = !isBoundaryPlus

        while interval <= 1 {
            possiblePSegment = pSegmentIterator.next()
            possibleQSegment = qSegmentIterator.next()

            if stillNeedToCheckQ, let qSegment = possibleQSegment {
                assert(possiblePSegment == nil)
                interval = qSegment.id - Segment.Identifier.min

                if interval == 0 {
                    newPositionSegments.append(qSegment)
                } else {
                    if isBoundaryPlus || interval == 1 {
                        newPositionSegments.append(
                            Segment(id: Segment.Identifier.min, source: source)
                        )
                    } else {
                        newPositionSegments.append(qSegment)
                    }
                }

                if interval > 0 {
                    stillNeedToCheckQ = false
                }
            } else {
                if let pSegment = possiblePSegment {
                    interval = Segment.Identifier.max - pSegment.id

                    if interval == 0 {
                        newPositionSegments.append(pSegment)
                    } else {
                        if isBoundaryPlus {
                            newPositionSegments.append(pSegment)
                        } else {
                            newPositionSegments.append(
                                Segment(id: Segment.Identifier.max, source: source)
                            )
                        }
                    }
                } else {
                    interval = Segment.Identifier.max

                    if isBoundaryPlus {
                        newPositionSegments.append(Segment(id: Segment.Identifier.min, source: source))
                    } else {
                        newPositionSegments.append(Segment(id: Segment.Identifier.max, source: source))
                    }
                }
            }

            isBoundaryPlus = !isBoundaryPlus
        }

        assert(interval > 1)

        let step = min(boundary, interval - 1) // TODO: If the "- 1" is removed, need to add a final step to check if the lastPosition == 0, then retry again
        let lastIndex = newPositionSegments.count - 1

        var lastPosition = newPositionSegments[lastIndex].id
        if lastIndex % 2 == 0 {
            lastPosition += Segment.Identifier.random(in: 1...step)
        } else {
            lastPosition -= Segment.Identifier.random(in: 1...step)
        }
        newPositionSegments[lastIndex] = Segment(id: lastPosition, source: source)

//        print("Level: \(lastIndex), Boundary: \(boundary), Interval: \(interval), Step: \(step), PositionType.Segments: \(newPositionSegments)")

        return newPositionSegments
    }
}

/// PositionSegment represents a part of the position at a specific depth.
public protocol PositionSegment: Comparable {
    associatedtype Identifier where Identifier: Comparable & FixedWidthInteger & BinaryInteger

    associatedtype Source where Source: Comparable & FixedWidthInteger & BinaryInteger

    init(id: Identifier, source: Source)

    var id: Identifier { get }

    var source: Source { get }
}

extension PositionSegment {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.id < rhs.id {
            return true
        } else if lhs.id == rhs.id {
            return lhs.source < rhs.source
        }

        return false
    }
}
