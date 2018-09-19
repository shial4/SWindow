// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SWindow",
    products: [
        .library(
            name: "SWindow",
            targets: ["SWindow"]
        )
    ],
    targets: [
        .target(name: "SWindow")
    ]
)

