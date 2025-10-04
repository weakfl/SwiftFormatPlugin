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
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.58.3/swiftformat.artifactbundle.zip",
            checksum: "349130edf42691b1e94f0a5f9a7914bbd38a817d462a63e41a88178908ec6479"
        )
    ]
)
