import Foundation
import PackagePlugin

protocol PluginToolProviding {
    func tool(named name: String) throws -> PackagePlugin.PluginContext.Tool
    var pluginWorkDirectory: PackagePlugin.Path { get }
}

extension PluginContext: PluginToolProviding {}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension XcodePluginContext: PluginToolProviding {}
#endif
