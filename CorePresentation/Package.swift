// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CorePresentation",
	platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CorePresentation",
            targets: ["CorePresentation"]
        ),
    ],
	dependencies: [
		.package(path: "../CoreModule"),
		.package(path: "../DesignSystem")
	],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CorePresentation",
			dependencies: [
				.product(name: "CoreModule", package: "CoreModule"),
				.product(name: "DesignSystem", package: "DesignSystem"),
			],
        ),
        .testTarget(
            name: "CorePresentationTests",
            dependencies: ["CorePresentation"]
        ),
    ]
)
