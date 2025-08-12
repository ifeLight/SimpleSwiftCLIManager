# SimpleSwiftCLIManager

A flexible Swift package for building command-line interfaces with modular operation management and ArgumentParser integration.

## Overview

SimpleSwiftCLIManager is a Swift package that provides a clean, modular architecture for building CLI applications. It separates the core CLI management logic from the executable entry points, making it easy to create, test, and maintain command-line tools with both structured command parsing and string-based command handling.

## Project Structure

```
Sources/
├── CLIManager/
│   ├── CLIManager.swift        # Core module with CLIManager class and Command struct
│   └── Enums.swift            # Action and Resource enums
├── CLIManagerExecutable/
│   └── main.swift             # Standard ArgumentParser executable entry point
└── StringCommandExecutable/
    └── main.swift             # String-based command parsing executable
Tests/
└── SimpleSwiftCLIManagerTests/
    └── SimpleSwiftCLIManagerTests.swift # Unit tests
```

## Features

- **Modular Design**: Separate CLI logic from executable entry points
- **Dual Execution Modes**: Support for both ArgumentParser-based and string-based command parsing
- **Operation Registration**: Dynamic registration of action/resource combinations
- **ArgumentParser Integration**: Built-in support for structured command-line argument parsing
- **String Command Processing**: Parse and execute commands from string input
- **Testable Architecture**: Easy to unit test CLI operations
- **Type-Safe Operations**: Enum-based Action and Resource definitions
- **Rich Operation Arguments**: Support for optional parameters like data, pagination, verbose output, etc.

## Installation

### Swift Package Manager

Add this package as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ifeLight/SimpleSwiftCLIManager.git", from: "1.0.0")
]
```

Then add `CLIManager` as a dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["CLIManager"]
)
```

## Usage

### Basic Usage

1. **Import the CLIManager module**:

```swift
import CLIManager
```

2. **Create and configure a CLIManager instance**:

```swift
let cliManager = CLIManager()

// Register operations using Action and Resource enums
cliManager.registerOperation(.add, .numbers) { operationArgs in
    let numbers = operationArgs.values.compactMap { Int($0) }
    let result = numbers.reduce(0, +)
    print("Result: \(result)")
}

cliManager.registerOperation(.multiply, .numbers) { operationArgs in
    let numbers = operationArgs.values.compactMap { Int($0) }
    let result = numbers.reduce(1, *)
    print("Result: \(result)")
}
```

### Execution Modes

This package provides two different executable entry points:

#### 1. ArgumentParser Mode (CLIManagerExecutable)

For structured command-line argument parsing:

```swift
import ArgumentParser
import CLIManager

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

func setupCLIManager() -> CLIManager {
    let cliManager = CLIManager()
    
    // Dynamically register all combinations of Action and Resource
    for action in Action.allCases {
        for resource in Resource.allCases {
            cliManager.registerOperation(action, resource) { operationArgs in
                print("Action: \(operationArgs.action), Resource: \(operationArgs.resource)")
                print("Values: \(operationArgs.values)")
            }
        }
    }
    
    return cliManager
}
```

#### 2. String Command Mode (StringCommandExecutable)

For parsing commands from string input with custom logic:

```swift
import CLIManager
import Foundation

@main
struct StringCommandExecutable {
    static func main() async {
        let cliManager = CLIManager()
        
        // Register specific operations with custom implementations
        cliManager.registerOperation(.add, .numbers) { args in
            let numbers = args.values.compactMap { Int($0) }
            let result = numbers.reduce(0, +)
            print("Add Numbers Result: \(result)")
        }
        
        cliManager.registerOperation(.get, .camera) { args in
            print("Getting camera info: \(args.data ?? "No data")")
        }
        
        // Parse command from string or command line arguments
        let input = CommandLine.arguments.dropFirst().joined(separator: " ")
        let argsList = input.isEmpty ? ["add", "numbers", "1", "2", "3"] : input.split(separator: " ").map(String.init)
        
        let command = try Command.parse(argsList)
        let args = makeCLICallbackArgs(from: command)
        cliManager.executeOperation(args: args)
    }
}
```

### Available Actions and Resources

The CLIManager comes with predefined Action and Resource enums:

```swift
public enum Action: String, ExpressibleByArgument, Hashable, CaseIterable {
    case add
    case subtract
    case multiply
    case divide
    case get
    case rotate
    case search
}

public enum Resource: String, ExpressibleByArgument, Hashable, CaseIterable {
    case numbers
    case camera
    case stars
    case moon
}
```

### Operation Arguments

Operations receive arguments through the `OperationArgs` protocol:

```swift
public protocol OperationArgs {
    var action: Action { get }
    var resource: Resource { get }
    var values: [String] { get }
    var data: String? { get }
    var page: Int? { get }
    var skip: Int? { get }
    var verbose: Bool? { get }
    var output: String? { get }
    var silent: Bool { get }
}
```

The `CLICallbackArgs` struct implements this protocol and provides all the rich functionality for command handling.

## Example: Practical Usage Examples

Here are some practical examples showing how to use the different execution modes:

### Calculator CLI (ArgumentParser Mode)

```swift
import CLIManager
import ArgumentParser

@main
struct CalculatorCLI {
    static func main() async {
        await MainActor.run {
            Command.cliManager = setupCalculator()
        }
        await Command.main()
    }
}

func setupCalculator() -> CLIManager {
    let cliManager = CLIManager()
    
    // Math operations on numbers
    cliManager.registerOperation(.add, .numbers) { args in
        let numbers = args.values.compactMap { Double($0) }
        let result = numbers.reduce(0, +)
        print("Addition Result: \(result)")
    }
    
    cliManager.registerOperation(.subtract, .numbers) { args in
        let numbers = args.values.compactMap { Double($0) }
        let result = numbers.dropFirst().reduce(numbers.first ?? 0) { $0 - $1 }
        print("Subtraction Result: \(result)")
    }
    
    cliManager.registerOperation(.multiply, .numbers) { args in
        let numbers = args.values.compactMap { Double($0) }
        let result = numbers.reduce(1, *)
        print("Multiplication Result: \(result)")
    }
    
    // Camera operations
    cliManager.registerOperation(.get, .camera) { args in
        print("Getting camera info: \(args.data ?? "default settings")")
        if args.verbose == true {
            print("Verbose mode: Showing detailed camera information")
        }
    }
    
    return cliManager
}
```

### String-Based Command Processing

The StringCommandExecutable shows how to handle commands from string input, which is useful for:
- Interactive command shells
- Processing commands from configuration files
- API endpoints that accept command strings

```swift
// Example from StringCommandExecutable implementation
cliManager.registerOperation(.add, .numbers) { args in
    let numbers = args.values.compactMap { Int($0) }
    let result = numbers.reduce(0, +)
    print("Add Numbers Result: \(result)")
}

cliManager.registerOperation(.search, .moon) { args in
    print("Searching moon with values: \(args.values)")
    if let data = args.data {
        print("Using search criteria: \(data)")
    }
}
```


## Running the CLI

You can run your CLI tool in two ways:


### 1. Directly with Swift (Recommended for development)

You can use `swift run CLIManagerExecutable` or `swift run StringCommandExecutable` to run the CLI directly:

#### CLIManagerExecutable (ArgumentParser Mode)
```bash
# Math operations
swift run CLIManagerExecutable add numbers 10 5 3
# Output: Action: add, Resource: numbers, Values: ["10", "5", "3"]

# With optional parameters
swift run CLIManagerExecutable get camera --data "ISO800" --verbose
# Output: Action: get, Resource: camera, Values: []
#         Data: ISO800
#         Verbose mode enabled

# Other resource combinations
swift run CLIManagerExecutable rotate stars "Orion" "Polaris"
swift run CLIManagerExecutable search moon --page 1 --skip 10
```

#### StringCommandExecutable (String Command Mode)
```bash
# Math operations with actual calculations
swift run StringCommandExecutable add numbers 1 2 3 4
# Output: Add Numbers Result: 10

# Default behavior (runs "add numbers 1 2 3")
swift run StringCommandExecutable
# Output: Add Numbers Result: 6

# Camera operations
swift run StringCommandExecutable get camera
# Output: Getting camera info: No data

# Astronomy operations
swift run StringCommandExecutable search moon crater maria
# Output: Searching moon with values: ["crater", "maria"]
```

### 2. Install as a Global Command (Recommended for users)

You can install your CLI tool globally using the provided `install.sh` script. This script wraps the `CLIManagerExecutable` and lets you run commands like `aos-cli add numbers 2 3` from anywhere on your system.

**How to install:**
1. Make the script executable:
    ```sh
    chmod +x install.sh
    ```
2. Run the script:
    ```sh
    ./install.sh
    ```
3. By default, the command will be installed as `/usr/local/bin/aos-cli`. You can change the command name by editing the `TARGET_NAME` variable in `install.sh` before running the script.

**Example usage:**
```sh
aos-cli add numbers 2 3
aos-cli get camera --data "ISO800"
aos-cli search moon crater maria
```

---

You do not need to know the full contents of the install script—just configure the `TARGET_NAME` variable to set your preferred command name.

## Testing

The CLIManager is designed to be easily testable. Here are examples from the test suite:

```swift
import Testing
@testable import CLIManager

@Test("Addition operation should print correct values")
func testAdditionOperation() async throws {
    // Arrange
    let cliManager = CLIManager()
    var output = ""
    cliManager.registerOperation(.add, .numbers) { args in
        output = "Performing addition with values: \(args.values)"
    }
    let args = CLICallbackArgs(action: .add, resource: .numbers, values: ["2", "3"])
    
    // Act
    cliManager.executeOperation(args: args)
    
    // Assert
    #expect(output == "Performing addition with values: [\"2\", \"3\"]")
}

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
    
    // Act
    try await command.run()
    
    // Assert
    #expect(output == "Performing addition with values: [\"2\", \"3\"]")
}
```

Run tests with:
```bash
swift test
```

## API Reference

### CLIManager

The main class for managing CLI operations.

#### Methods

- `registerOperation(_:_:function:)` - Register a function for a specific Action and Resource combination
- `executeOperation(args:)` - Execute a registered operation with the given arguments

### Command

The ArgumentParser command struct that handles command-line parsing.

#### Properties

- `action: Action` - The action to perform
- `resource: Resource` - The resource to perform the action on  
- `values: [String]` - The values to use in the operation
- `data: String?` - Optional data string
- `page: Int?` - Optional page number for pagination
- `skip: Int?` - Optional skip count for pagination
- `verbose: Bool` - Enable verbose output
- `output: String?` - Optional output string
- `silent: Bool` - Suppress all output

### Action Enum

Available actions: `add`, `subtract`, `multiply`, `divide`, `get`, `rotate`, `search`

### Resource Enum

Available resources: `numbers`, `camera`, `stars`, `moon`

### OperationArgs Protocol

Protocol defining the structure of operation arguments with rich parameter support.

### CLICallbackArgs

Struct implementing `OperationArgs` that provides all the functionality for handling command arguments and optional parameters.

## Requirements

- Swift 6.0+
- macOS 10.15+, iOS 13+, tvOS 13+, watchOS 6+
- ArgumentParser 1.3.0+

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for your changes
4. Ensure all tests pass
5. Submit a pull request

## License

This project is available under the MIT license. See the LICENSE file for more info.