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

/// Convergent Replicate Date Type or a state-based CRDT. CvRDTs send their entire state
/// to all replicas. CvRDT instances are able to merge with other instances and converge to
/// the lower upper bound value.
public protocol CvRDT: PartialOrderable {
    /// An idempotent and commutative function which attempts to merge the other instance's state
    /// with this instance's state.
    ///
    /// - Parameter other: The other instance
    /// - Throws: Throws an error if the states could not be merged.
    mutating func merge(_ other: Self) throws
}
