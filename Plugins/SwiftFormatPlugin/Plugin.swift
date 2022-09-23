//
//  File.swift
//
//
//  Created by weak on 23.09.22.
//

import Foundation
import PackagePlugin

@main
struct SwiftFormatPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        let fileManager = FileManager.default

        // Possible paths where there may be a config file (root of package, target dir.)
        let configurations: [Path] = [context.package.directory, target.directory]
            .map { $0.appending(".swiftformat") }
            .filter { fileManager.fileExists(atPath: $0.string) }

        // Validate paths list
        guard validate(configurations: configurations, target: target) else {
            return []
        }

        // Clear the SwiftFormat plugin's directory (in case of dangling files)
        fileManager.forceClean(directory: context.pluginWorkDirectory)

        return try configurations.map { configuration in
            try .swiftformat(using: configuration, context: context, target: target)
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftFormatPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let fileManager = FileManager.default

        // Possible paths where there may be a config file (root of package, target dir.)
        let configurations: [Path] = [context.xcodeProject.directory]
            .map { $0.appending(".swiftformat") }
            .filter { fileManager.fileExists(atPath: $0.string) }

        // Validate paths list
        guard validate(configurations: configurations, target: target) else {
            return []
        }

        // Clear the SwiftFormat plugin's directory (in case of dangling files)
        fileManager.forceClean(directory: context.pluginWorkDirectory)

        return try configurations.map { configuration in
            try .swiftformat(using: configuration, context: context, target: target)
        }
    }
}
#endif

// MARK: - Helpers

private extension SwiftFormatPlugin {
    /// Validate the given list of configurations
    func validate(configurations: [Path], target: Target) -> Bool {
        guard !configurations.isEmpty else {
            Diagnostics.error("""
            No SwiftFormat configurations found for target \(target.name). If you would like to generate sources for this \
            target include a `.swiftformat` in the target's source directory, or include a shared `.swiftformat` at the \
            package's root.
            """)
            return false
        }

        return true
    }

    #if canImport(XcodeProjectPlugin)
    func validate(configurations: [Path], target: XcodeTarget) -> Bool {
        guard !configurations.isEmpty else {
            Diagnostics.error("""
            No SwiftFormat configurations found for target \(target.displayName). If you would like to generate sources for this \
            target include a `.swiftformat` in the target's source directory, or include a shared `.swiftformat` at the \
            package's root.
            """)
            return false
        }

        return true
    }
    #endif
}

private extension Command {
    static func swiftformat(using configuration: Path, context: PluginContext, target: Target) throws -> Command {
        .prebuildCommand(
            displayName: "SwiftFormat BuildTool Plugin",
            executable: try context.tool(named: "swiftformat").path,
            arguments: [
                "--config", "\(configuration)",
                target.directory
            ],
            environment: [
                "PROJECT_DIR": context.package.directory,
                "TARGET_NAME": target.name,
                "PRODUCT_MODULE_NAME": target.moduleName,
                "DERIVED_SOURCES_DIR": context.pluginWorkDirectory
            ],
            outputFilesDirectory: context.pluginWorkDirectory
        )
    }

    #if canImport(XcodeProjectPlugin)
    static func swiftformat(using configuration: Path, context: XcodePluginContext, target: XcodeTarget) throws -> Command {
        .prebuildCommand(
            displayName: "SwiftFormat BuildTool Plugin",
            executable: try context.tool(named: "swiftformat").path,
            arguments: [
                "--config", "\(configuration)",
                context.xcodeProject.directory
            ],
            environment: [
                "PROJECT_DIR": context.xcodeProject.directory,
                "TARGET_NAME": target.displayName,
                "DERIVED_SOURCES_DIR": context.pluginWorkDirectory
            ],
            outputFilesDirectory: context.pluginWorkDirectory
        )
    }
    #endif
}

private extension FileManager {
    /// Re-create the given directory
    func forceClean(directory: Path) {
        try? removeItem(atPath: directory.string)
        try? createDirectory(atPath: directory.string, withIntermediateDirectories: false)
    }
}

extension Target {
    /// Try to access the underlying `moduleName` property
    /// Falls back to target's name
    var moduleName: String {
        switch self {
        case let target as SourceModuleTarget:
            return target.moduleName
        default:
            return ""
        }
    }
}
