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

/// PartialOrderable is a protocol for types where the type's state can be partially ordered
/// as a join-semilattice (where a least upper bound can be found for any non-empty instance
/// subset).
public protocol PartialOrderable: Equatable {
    static func < (lhs: Self, rhs: Self) -> Bool

    static func <= (lhs: Self, rhs: Self) -> Bool
}

// swiftlint:disable extension_access_modifier

extension PartialOrderable where Self: Comparable {
    /// Default implementation for <= when the type is Comparable.
    public static func <= (lhs: Self, rhs: Self) -> Bool {
        return !(rhs < lhs)
    }
}

// swiftlint:enable extension_access_modifier
