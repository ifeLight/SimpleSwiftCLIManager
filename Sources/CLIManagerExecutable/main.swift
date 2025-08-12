import ArgumentParser
import CLIManager

/// Configure your CLI operations here
/// This function is called automatically when the CLI starts
public func setupCLIManager() -> CLIManager {
    let cliManager = CLIManager()

    func cliCallback(operationArgs: CLICallbackArgs) {
        print(
            "Action: \(operationArgs.action), Resource: \(operationArgs.resource), Values: \(operationArgs.values)"
        )
        if let data = operationArgs.data {
            print("Data: \(data)")
        }
        if let page = operationArgs.page {
            print("Page: \(page)")
        }
        if let skip = operationArgs.skip {
            print("Skip: \(skip)")
        }
        if let verbose = operationArgs.verbose, verbose {
            print("Verbose mode enabled")
        }
        if let output = operationArgs.output {
            print("Output: \(output)")
        }
        if operationArgs.silent {
            print("Silent mode enabled")
        }
    }

    // Dynamically register all combinations of Action and Resource
    for action in Action.allCases {
        for resource in Resource.allCases {
            cliManager.registerOperation(action, resource, cliCallback)
        }
    }

    return cliManager
}

@available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 6, *)
@main
struct CLIExecutable {
    static func main() async {
        // Set up the CLI manager
        await MainActor.run {
            Command.cliManager = setupCLIManager()
        }

        // Run the command
        await Command.main()
    }
}
