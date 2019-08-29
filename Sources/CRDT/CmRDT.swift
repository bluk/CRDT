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

/// Commutative Replicated Data or an operation-based CRDT. CmRDTs produce operations which
/// cause a replica's state to eventually converge to the desired final state if all operations are causally delivered.
public protocol CmRDT: PartialOrderable {
    associatedtype CRDTOperation

    /// Applies an operation which updates the instance's state.
    ///
    /// - Parameter operation:The operation which can update the state
    /// - Throws: Throws an error if the operation cannot be applied.
    mutating func apply(_ operation: CRDTOperation) throws
}
