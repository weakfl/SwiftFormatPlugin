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
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.60.0/swiftformat.artifactbundle.zip",
            checksum: "2728f78f4a1a07e54a1df40b4f88f9673eafe1b814c9358e4bbefa2edccb0458"
        )
    ]
)
