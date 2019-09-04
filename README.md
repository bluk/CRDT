# CRDT

A [Swift][swift] package to help build [Convergent and Commutative Replicated Data Types][crdt].

CRDTs are useful for synchronizing data which eventually converges to a consistent state. CRDTs can be
useful when nodes/replicas may not be able to directly communicate with each other. CRDTs can be used
instead of an always active foreground synchronization protocol.

## Usage

### Swift Package Manager

Add this package to your `Package.swift` `dependencies` and target's `dependencies`:

```swift
import PackageDescription

let package = Package(
    name: "Example",
    dependencies: [
        .package(
            url: "https://github.com/bluk/CRDT",
            from: "0.1.0"
        ),
    ],
    targets: [
        .target(
            name: "YourProject",
            dependencies: ["CRDT"]
        )
    ]
)
```

### Code

```swift
import Foundation

import CRDT

// First system
let actorA = UUID()
var a = GCounter<UUID>()

a.incrementCounter(for: actorA)
// a.value == 1

// Second system
let actorB = UUID()
var b = GCounter<UUID>()

b.incrementCounter(for: actorB)
// b.value == 1

try b.merge(a)
// b.value == 2

a.incrementCounter(for: actorA)
a.incrementCounter(for: actorA)
// a.value == 3

try b.merge(a)
// b.value == 4
```

See the tests for more examples.

## Related Links

See other projects which have implementations for CRDTs:

* [rust-crdt][rust_crdt]
* [java-crdt][java_crdt]

## License

[Apache-2.0 License][license]

[license]: LICENSE
[swift]: https://swift.org
[crdt]: https://hal.inria.fr/file/index/docid/555588/filename/techreport.pdf
[rust_crdt]: https://github.com/rust-crdt/rust-crdt
[java_crdt]: https://github.com/ajantis/java-crdt
