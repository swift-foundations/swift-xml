// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-xml",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(name: "XML", targets: ["XML"])
    ],
    dependencies: [
        .package(path: "../../swift-standards/swift-w3c-xml"),
        .package(path: "../swift-async")
    ],
    targets: [
        .target(
            name: "XML",
            dependencies: [
                .product(name: "W3C XML", package: "swift-w3c-xml"),
                .product(name: "Async", package: "swift-async")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
