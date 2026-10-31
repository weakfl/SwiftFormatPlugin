# SwiftFormatPlugin

Swift Package Manager plugins for [SwiftFormat](https://github.com/nicklockwood/SwiftFormat), using the prebuilt SwiftFormat binary.

Forked from [MarcoEidinger/SwiftFormatPlugin](https://github.com/MarcoEidinger/SwiftFormatPlugin), which is no longer maintained.

## Why this fork

- **Fast builds**: SwiftFormat ships as a prebuilt binary, so it doesn't get compiled from source (unlike depending on `nicklockwood/SwiftFormat` directly).
- **Format on build**: a build tool plugin formats your code before every build, not just on demand.
- **One config for the whole project**: in an Xcode project, both plugins format the entire project directory with the `.swiftformat` at its root, including local packages that live inside it.
- **Local dependencies included**: `--target X` also formats the targets X depends on within the same package.
- **Always current**: an [hourly workflow](.github/workflows/update.yml) picks up new SwiftFormat releases. Each version is tagged `vX.Y.Z` and matches the [SwiftFormat release](https://github.com/nicklockwood/SwiftFormat/releases) of the same number.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/weakfl/SwiftFormatPlugin", from: "0.64.5"),
]
```

## Configuration

Both plugins read a `.swiftformat` file:

| Context       | Config lookup                                  |
| ------------- | ---------------------------------------------- |
| Swift package | package root and/or the target's directory     |
| Xcode project | project root                                   |

The build tool plugin fails the build if no config is found. If both the package root and the target directory contain one, SwiftFormat runs once per config.

## Build tool plugin: `SwiftFormatPlugin`

Formats code before each build.

### Swift package

```swift
.target(
    name: "MyLibrary",
    plugins: [.plugin(name: "SwiftFormatPlugin", package: "SwiftFormatPlugin")]
)
```

This formats the target's directory.

### Xcode project

Add `SwiftFormatPlugin` under the target's *Build Phases → Run Build Tool Plug-ins*. This formats the whole project directory.

## Command plugin: `SwiftFormat`

Formats code on demand.

### Swift package

```bash
swift package --allow-writing-to-package-directory swiftformat
```

- Without `--target`, every target is formatted.
- `--target MyLibrary` formats `MyLibrary` plus its local dependencies. Pass it multiple times to select more targets.
- Any other arguments go to SwiftFormat, e.g. `--swift-version 6.0` or `--lint`.

### Xcode project

Right-click the project in the navigator and choose *SwiftFormat*. The whole project directory is formatted, and `--target` is ignored.
