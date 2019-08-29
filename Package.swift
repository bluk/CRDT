// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CRDT",
    products: [
        .library(
            name: "CRDT",
            targets: ["CRDT"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "CRDT",
            dependencies: []
        ),
        .testTarget(
            name: "CRDTTests",
            dependencies: ["CRDT"]
        ),
    ]
)