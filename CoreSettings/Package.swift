// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CoreSettings",
	platforms: [.macOS(.v13), .iOS(.v16)],
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(
			name: "CoreSettings",
			targets: ["CoreSettings"]),
	],
	dependencies: [.package(path: "../CoreModule")],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "CoreSettings",
			dependencies: [.product(name: "CoreModule", package: "CoreModule")]
		),
		.testTarget(
			name: "CoreSettingsTests",
			dependencies: ["CoreSettings"]
		),
	]
)
