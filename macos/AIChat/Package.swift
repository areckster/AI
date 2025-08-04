// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AIChat",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "AIChat", targets: ["AIChat"])
    ],
    targets: [
        .executableTarget(
            name: "AIChat",
            path: "."
        )
    ]
)
