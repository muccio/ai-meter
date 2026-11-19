// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AIMeter",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "AIMeter", targets: ["AIMeter"]),
        .library(name: "AIMeterCore", targets: ["AIMeterCore"])
    ],
    targets: [
        .target(
            name: "AIMeterCore",
            path: "Sources/AIMeterCore"
        ),
        .executableTarget(
            name: "AIMeter",
            dependencies: ["AIMeterCore"],
            path: "Sources/AIMeter"
        ),
        .testTarget(
            name: "AIMeterTests",
            dependencies: ["AIMeterCore"],
            path: "Tests/AIMeterTests"
        )
    ]
)
