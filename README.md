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

## License

[Apache-2.0 License][license]

[license]: LICENSE
[swift]: https://swift.org
[crdt]: https://hal.inria.fr/file/index/docid/555588/filename/techreport.pdf
