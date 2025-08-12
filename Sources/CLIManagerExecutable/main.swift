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

    func calcCallBack(args: CLICallbackArgs) -> Any? {
        let numbers = args.values.compactMap { Double($0) }
        let result: Double
        if numbers.isEmpty {
            result = 0
        } else {
            switch args.action {
            case .add:
                result = numbers.reduce(0, +)
            case .subtract:
                result = numbers.reduce(numbers.first ?? 0) { $0 - $1 }
            case .multiply:
                result = numbers.reduce(1, *)
            case .divide:
                result = numbers.dropFirst().reduce(numbers.first ?? 1) { $0 / $1 }
            default:
                print("Unsupported action: \(args.action)")
                return nil
            }
        }
        print("Calculation Result: \(result)")
        return result
    }

    // Dynamically register all combinations of Action and Resource
    for action in Action.allCases {
        for resource in Resource.allCases {
            if action == .add || action == .subtract || action == .multiply
                || action == .divide && resource == .numbers
            {
                cliManager.registerOperation(action, resource, calcCallBack)
            } else {
                cliManager.registerOperation(action, resource, cliCallback)
            }
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
