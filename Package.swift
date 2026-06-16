// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AfterpartyKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "AfterpartyKit", targets: ["AfterpartyKit"])
    ],
    targets: [
        .target(
            name: "AfterpartyKit",
            path: "Sources/AfterpartyKit"
        ),
        .testTarget(
            name: "AfterpartyKitTests",
            dependencies: ["AfterpartyKit"],
            path: "Tests/AfterpartyKitTests"
        )
    ]
)
