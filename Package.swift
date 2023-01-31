// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "SwiftFormatPlugin",
    products: [
        .plugin(name: "SwiftFormatPlugin", targets: ["SwiftFormatPlugin"]),
        .plugin(name: "SwiftFormat", targets: ["SwiftFormat"]),
    ],
    dependencies: [],
    targets: [
        .plugin(
            name: "SwiftFormatPlugin",
            capability: .buildTool(),
            dependencies: ["swiftformat"]
        ),
        .plugin(
            name: "SwiftFormat",
            capability: .command(
                intent: .custom(
                    verb: "swiftformat",
                    description: "Formats source code"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "This command reformats source files"),
                ]
            ),
            dependencies: [.target(name: "swiftformat")]
        ),
        .binaryTarget(
            name: "swiftformat",
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.50.8/swiftformat.artifactbundle.zip",
            checksum: "0e59f64a40e5d02df5a38414a9ef46d559625c230bb78e15a0ba0451a9825e0e"
        )
    ]
)
