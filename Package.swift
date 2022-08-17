// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BJOTPViewController",
    platforms: [.iOS(.v11), .macCatalyst(.v13)],
    products: [
        .library(
            name: "BJOTPViewController",
            targets: ["BJOTPViewController"]),
    ],
    targets: [
        .target(
            name: "BJOTPViewController",
            dependencies:[]
        ),
    ],
    swiftLanguageVersions: [SwiftVersion.version("4.0")]
)
