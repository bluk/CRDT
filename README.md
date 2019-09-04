# CRDT

A [Swift][swift] package to help build [Convergent and Commutative Replicated Data Types][crdt].

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
