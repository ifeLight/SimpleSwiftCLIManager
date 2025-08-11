import CLIManager
import Foundation

func setupCLIManager() -> CLIManager {
    let cliManager = CLIManager()

    // Register reasonable operations for each Action/Resource
    cliManager.registerOperation(.add, .numbers) { args in
        let numbers = args.values.compactMap { Int($0) }
        let result = numbers.reduce(0, +)
        print("Add Numbers Result: \(result)")
    }

    cliManager.registerOperation(.subtract, .numbers) { args in
        let numbers = args.values.compactMap { Int($0) }
        let result = numbers.dropFirst().reduce(numbers.first ?? 0) { $0 - $1 }
        print("Subtract Numbers Result: \(result)")
    }

    cliManager.registerOperation(.multiply, .numbers) { args in
        let numbers = args.values.compactMap { Int($0) }
        let result = numbers.reduce(1, *)
        print("Multiply Numbers Result: \(result)")
    }

    cliManager.registerOperation(.divide, .numbers) { args in
        let numbers = args.values.compactMap { Double($0) }
        let result = numbers.dropFirst().reduce(numbers.first ?? 0) { $0 / $1 }
        print("Divide Numbers Result: \(result)")
    }

    cliManager.registerOperation(.get, .camera) { args in
        print("Getting camera info: \(args.data ?? "No data")")
    }

    cliManager.registerOperation(.rotate, .stars) { args in
        print("Rotating stars with values: \(args.values)")
    }

    cliManager.registerOperation(.search, .moon) { args in
        print("Searching moon with values: \(args.values)")
    }

    return cliManager
}

@main
struct StringCommandExecutable {
    static func main() async {
        // Get input from command line arguments if available
        let defaultInput = "add numbers 1 2 3"
        let input: String
        let cliArgs = Array(CommandLine.arguments.dropFirst())
        if !cliArgs.isEmpty {
            print("Command line arguments:", cliArgs)
            input = cliArgs.joined(separator: " ")
        } else {
            input = defaultInput
        }

        // Set up the CLI manager
        await MainActor.run {
            Command.cliManager = setupCLIManager()
        }

        var command: Command?
        do {
            let argsList = input.split(separator: " ").map(String.init)
            print("Parsed args:", argsList)
            command = try Command.parse(argsList)
        } catch {
            print("Error: \(error.localizedDescription)")
        }

        if let command = command, let cliManager = Command.cliManager {
            let args = makeCLICallbackArgs(from: command)
            cliManager.executeOperation(args: args)
        } else {
            print("Command or CLI Manager is not set up correctly.")
        }
    }
}
