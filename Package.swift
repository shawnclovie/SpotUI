// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SpotUI",
	platforms: [
		.iOS("9.0"),
	],
    products: [
        .library(name: "SpotUI", targets: ["SpotUI"]),
    ],
    dependencies: [
		.package(url: "https://github.com/shawnclovie/Spot",
				 from: "1.1.0"),
		.package(url: "https://github.com/shawnclovie/SpotCache",
				 from: "1.0.0"),
    ],
    targets: [
        .target(name: "SpotUI", dependencies: ["Spot", "SpotCache"]),
    ]
)
