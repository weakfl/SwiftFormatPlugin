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
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.51.4/swiftformat.artifactbundle.zip",
            checksum: "6e86973183fe1ed1b779a12731f901e8630bf3583ae52e54856bcc8d944568f8"
        )
    ]
)
