# CLIManager

A flexible Swift package for building command-line interfaces with modular operation management and ArgumentParser integration.

## Overview

CLIManager is a Swift package that provides a clean, modular architecture for building CLI applications. It separates the core CLI management logic from the executable entry point, making it easy to create, test, and maintain command-line tools.

## Project Structure

```
Sources/
├── CLIManager/
│   └── CLIManager.swift        # Core module with CLIManager class and Command struct
└── CLIManagerExecutable/
    └── main.swift              # Executable entry point
Tests/
└── SwiftExampleTests/
    └── SwiftExampleTests.swift # Unit tests
```

## Features

- **Modular Design**: Separate CLI logic from executable entry point
- **Operation Registration**: Dynamic registration of operations and sub-operations
- **ArgumentParser Integration**: Built-in support for command-line argument parsing
- **Testable Architecture**: Easy to unit test CLI operations
- **Type-Safe Operations**: Enum-based operation and sub-operation definitions

## Installation

### Swift Package Manager

Add this package as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "your-repo-url", from: "1.0.0")
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

// Register operations
cliManager.registerOperation(.add, .add) { operationArgs in
    let numbers = operationArgs.values.compactMap { Int($0) }
    let result = numbers.reduce(0, +)
    print("Result: \(result)")
}

cliManager.registerOperation(.multiply, .multiply) { operationArgs in
    let numbers = operationArgs.values.compactMap { Int($0) }
    let result = numbers.reduce(1, *)
    print("Result: \(result)")
}
```

3. **Set up the CLI and run**:

```swift
import ArgumentParser

@main
struct MyCLI {
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
    
    cliManager.registerOperation(.add, .add) { operationArgs in
        let numbers = operationArgs.values.compactMap { Int($0) }
        let result = numbers.reduce(0, +)
        print("Addition result: \(result)")
    }
    
    cliManager.registerOperation(.subtract, .subtract) { operationArgs in
        let numbers = operationArgs.values.compactMap { Int($0) }
        guard numbers.count >= 2 else {
            print("Need at least 2 numbers for subtraction")
            return
        }
        let result = numbers.dropFirst().reduce(numbers.first!) { $0 - $1 }
        print("Subtraction result: \(result)")
    }
    
    return cliManager
}
```

### Available Operations and Sub-Operations

The CLIManager comes with predefined operation types:

```swift
public enum Operation: String, ExpressibleByArgument, Hashable {
    case add
    case subtract
    case multiply
    case divide
}

public enum SubOperation: String, ExpressibleByArgument, Hashable {
    case add
    case subtract
    case multiply
    case divide
}
```

### Custom Operation Arguments

Operations receive arguments through the `OperationArgs` protocol:

```swift
public protocol OperationArgs {
    var operation: Operation { get }
    var subOperation: SubOperation { get }
    var values: [String] { get }
}
```

## Example: Building a Calculator CLI

Here's a complete example of building a calculator CLI:

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
    
    // Addition
    cliManager.registerOperation(.add, .add) { args in
        let numbers = args.values.compactMap { Double($0) }
        let result = numbers.reduce(0, +)
        print("📊 Addition: \(numbers.map { String($0) }.joined(separator: " + ")) = \(result)")
    }
    
    // Subtraction
    cliManager.registerOperation(.subtract, .subtract) { args in
        let numbers = args.values.compactMap { Double($0) }
        guard numbers.count >= 2 else {
            print("❌ Error: Need at least 2 numbers for subtraction")
            return
        }
        let result = numbers.dropFirst().reduce(numbers.first!) { $0 - $1 }
        print("📊 Subtraction: \(numbers.map { String($0) }.joined(separator: " - ")) = \(result)")
    }
    
    // Multiplication
    cliManager.registerOperation(.multiply, .multiply) { args in
        let numbers = args.values.compactMap { Double($0) }
        let result = numbers.reduce(1, *)
        print("📊 Multiplication: \(numbers.map { String($0) }.joined(separator: " × ")) = \(result)")
    }
    
    // Division
    cliManager.registerOperation(.divide, .divide) { args in
        let numbers = args.values.compactMap { Double($0) }
        guard numbers.count >= 2 else {
            print("❌ Error: Need at least 2 numbers for division")
            return
        }
        
        let result = numbers.dropFirst().reduce(numbers.first!) { dividend, divisor in
            guard divisor != 0 else {
                print("❌ Error: Division by zero")
                return dividend
            }
            return dividend / divisor
        }
        print("📊 Division: \(numbers.map { String($0) }.joined(separator: " ÷ ")) = \(result)")
    }
    
    return cliManager
}
```

### Running the CLI

Once built, you can run your CLI with:

```bash
# Addition
swift run YourCLI add add 10 5 3
# Output: 📊 Addition: 10.0 + 5.0 + 3.0 = 18.0

# Subtraction  
swift run YourCLI subtract subtract 20 5 2
# Output: 📊 Subtraction: 20.0 - 5.0 - 2.0 = 13.0

# Multiplication
swift run YourCLI multiply multiply 4 3 2
# Output: 📊 Multiplication: 4.0 × 3.0 × 2.0 = 24.0

# Division
swift run YourCLI divide divide 100 5 2
# Output: 📊 Division: 100.0 ÷ 5.0 ÷ 2.0 = 10.0
```

## Testing

The CLIManager is designed to be easily testable:

```swift
import Testing
@testable import CLIManager

@Test("Test addition operation")
func testAddition() async throws {
    let cliManager = CLIManager()
    var result = ""
    
    cliManager.registerOperation(.add, .add) { args in
        let numbers = args.values.compactMap { Int($0) }
        let sum = numbers.reduce(0, +)
        result = "Sum: \(sum)"
    }
    
    struct TestArgs: OperationArgs {
        var operation: Operation = .add
        var subOperation: SubOperation = .add
        var values: [String] = ["5", "10", "15"]
    }
    
    cliManager.executeOperation(.add, .add, args: TestArgs())
    #expect(result == "Sum: 30")
}
```

## API Reference

### CLIManager

The main class for managing CLI operations.

#### Methods

- `registerOperation(_:_:function:)` - Register a function for a specific operation and sub-operation
- `executeOperation(_:_:args:)` - Execute a registered operation with the given arguments

### Command

The ArgumentParser command struct that handles command-line parsing.

#### Properties

- `operation: Operation` - The operation to perform
- `subOperation: SubOperation` - The sub-operation to perform  
- `values: [String]` - The values to use in the operation

### OperationArgs Protocol

Protocol defining the structure of operation arguments.

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