import ArgumentParser

public struct CLICallbackArgs {
    public var action: Action
    public var resource: Resource
    public var values: [String]
    public var data: String?
    public var page: Int?
    public var skip: Int?
    public var verbose: Bool?
    public var output: String?
    public var silent: Bool

    public init(
        action: Action,
        resource: Resource,
        values: [String],
        data: String? = nil,
        page: Int? = nil,
        skip: Int? = nil,
        verbose: Bool? = nil,
        output: String? = nil,
        silent: Bool = false
    ) {
        self.action = action
        self.resource = resource
        self.values = values
        self.data = data
        self.page = page
        self.skip = skip
        self.verbose = verbose
        self.output = output
        self.silent = silent
    }
}

public typealias CLIAction = Action
public typealias CLIResource = Resource
public typealias CLIOperationCallback = (CLICallbackArgs) -> Any?
public typealias CLIOperationArgs = CLICallbackArgs

public class CLIManager {
    public init() {}

    public var operationFuncs: [Action: [Resource: CLIOperationCallback]] = [:]

    public func registerOperation(
        _ action: Action, _ resource: Resource,
        _ function: @escaping CLIOperationCallback
    ) {
        if operationFuncs[action] == nil {
            operationFuncs[action] = [:]
        }
        operationFuncs[action]?[resource] = function
    }

    public func executeOperation(
        args: CLICallbackArgs
    ) -> Any? {
        let action = args.action
        let resource = args.resource
        guard let resources = operationFuncs[action],
            let function = resources[resource]
        else {
            print("No function registered for \(action) \(resource)")
            return nil
        }
        return function(args)
    }

}

public func makeCLICallbackArgs(from command: Command) -> CLICallbackArgs {
    return CLICallbackArgs(
        action: command.action,
        resource: command.resource,
        values: command.values,
        data: command.data,
        page: command.page,
        skip: command.skip,
        verbose: command.verbose,
        output: command.output,
        silent: command.silent
    )
}

public struct Command: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "aos-cli",
        abstract: "A command-line tool for performing operations.",
        discussion: """
            This tool allows you to perform various operations on different resources.
            """
    )

    @Argument(help: "The action to perform.")
    public var action: Action

    @Argument(help: "The resource to perform the action on.")
    public var resource: Resource

    @Argument(help: "The values to use in the action.")
    public var values: [String]

    @Option(name: .shortAndLong, help: "Optional data string.")
    public var data: String?

    @Option(name: .shortAndLong, help: "Optional page number.")
    public var page: Int?

    @Option(help: "Optional skip count.")
    public var skip: Int?

    @Flag(name: .shortAndLong, help: "Enable verbose output.")
    public var verbose: Bool = false

    @Option(name: .shortAndLong, help: "Optional output string.")
    public var output: String?

    @Flag(name: .shortAndLong, help: "Suppress all output.")
    public var silent: Bool = false

    public init() {}

    @MainActor
    public static var cliManager: CLIManager? = nil

    @MainActor
    public func run() async throws {
        print(
            "Running command with action: \(action), resource: \(resource), values: \(values)"
        )
        let args = CLICallbackArgs(
            action: action,
            resource: resource,
            values: values,
            data: data,
            page: page,
            skip: skip,
            verbose: verbose,
            output: output,
            silent: silent
        )
        guard let manager = Command.cliManager else {
            throw ValidationError("CLIManager is not initialized.")
        }
        _ = manager.executeOperation(args: args)
    }
}
