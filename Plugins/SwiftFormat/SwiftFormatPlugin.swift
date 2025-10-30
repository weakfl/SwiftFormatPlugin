import Foundation
import PackagePlugin

@main
struct SwiftFormatPlugin: CommandPlugin {
    /// This entry point is called when operating on a Swift package.
    func performCommand(context: PluginContext, arguments: [String]) throws {
        if arguments.contains("--verbose") {
            print("Command plugin execution with arguments \(arguments.description) for Swift package \(context.package.displayName). All target information: \(context.package.targets.description)")
        }

        var argExtractor = ArgumentExtractor(arguments)

        let selectedTargets = argExtractor.extractOption(named: "target")

        let targetsToProcess: [Target]
        if selectedTargets.isEmpty {
            targetsToProcess = context.package.targets
        } else {
            targetsToProcess = try context.package.allLocalTargets(of: selectedTargets)
        }

        for target in targetsToProcess {
            guard let target = target as? SourceModuleTarget else { continue }

            try formatCode(in: target.directory, context: context, arguments: argExtractor.remainingArguments)
        }
    }
}

extension Package {
    func allLocalTargets(of targetNames: [String]) throws -> [Target] {
        let matchingTargets = try targets(named: targetNames)
        let packageTargets = Set(targets.map(\.id))
        let withLocalDependencies = matchingTargets.flatMap { [$0] + $0.recursiveTargetDependencies }
            .filter { packageTargets.contains($0.id) }
        let enumeratedKeyValues = withLocalDependencies.map(\.id).enumerated()
            .map { (key: $0.element, value: $0.offset) }
        let indexLookupTable = Dictionary(enumeratedKeyValues, uniquingKeysWith: { l, _ in l })
        let groupedByID = Dictionary(grouping: withLocalDependencies, by: \.id)
        return groupedByID.map(\.value[0])
            .sorted { indexLookupTable[$0.id, default: 0] < indexLookupTable[$1.id, default: 0] }
    }
}
