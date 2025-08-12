import Testing

@testable import CLIManager

@Test("executeOperation should return the correct value")
func testExecuteOperationReturnValue() async throws {
    let cliManager = CLIManager()
    cliManager.registerOperation(.add, .numbers) { args in
        let numbers = args.values.compactMap { Int($0) }
        return numbers.reduce(0, +)
    }
    let args = CLICallbackArgs(action: .add, resource: .numbers, values: ["2", "3", "5"])
    let result = cliManager.executeOperation(args: args)
    #expect(result as? Int == 10)
}

@Test("Addition operation should print correct values")
func testAdditionOperation() async throws {
    // Arrange
    let cliManager = CLIManager()
    var output = ""
    cliManager.registerOperation(.add, .numbers) { args in
        output = "Performing addition with values: \(args.values)"
    }
    let args = CLICallbackArgs(action: .add, resource: .numbers, values: ["2", "3"])
    _ = cliManager.executeOperation(args: args)
    #expect(output == "Performing addition with values: [\"2\", \"3\"]")
}

@Test("CLIManager should register and execute operations")
func testCLIManagerExecution() async throws {
    let cliManager = CLIManager()
    var output = ""
    cliManager.registerOperation(.add, .numbers) { args in
        output = "Performing addition with values: \(args.values)"
    }
    let args = CLICallbackArgs(action: .add, resource: .numbers, values: ["2", "3"])
    _ = cliManager.executeOperation(args: args)
    #expect(output == "Performing addition with values: [\"2\", \"3\"]")
}

@available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 6, *)
@Test("Command struct should be accessible from CLIManager module")
func testCommandStructIsImportable() async throws {
    // Test that we can create a Command instance from CLIManager module
    var command = Command()
    command.action = .multiply
    command.resource = .numbers
    command.values = ["4", "5"]
    // Verify the command has the expected values
    #expect(command.action == .multiply)
    #expect(command.resource == .numbers)
    #expect(command.values == ["4", "5"])
}

@available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 6, *)
@Test("Command should execute and print output")
func testCommandExecution() async throws {
    let cliManager = CLIManager()
    var output = ""
    cliManager.registerOperation(.add, .numbers) { args in
        output = "Performing addition with values: \(args.values)"
    }
    // Set cliManager on MainActor
    await MainActor.run {
        Command.cliManager = cliManager
    }

    let command = try Command.parse(["add", "numbers", "2", "3"])

    do {
        // Act
        try await command.run()
    } catch {
        output = "Error: \(error)"
    }

    // Assert
    #expect(output == "Performing addition with values: [\"2\", \"3\"]")
}
