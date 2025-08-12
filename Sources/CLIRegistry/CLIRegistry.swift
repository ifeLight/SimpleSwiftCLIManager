/// A registry to manage CLI functions associated with hierarchical paths.
///
/// This class allows dynamic registration and invocation of functions using paths,
/// which can be provided as a string (dot-separated), an array of strings, or an array of enums with String raw values.
///
/// # Usage Examples
/// ```swift
/// let registry = CLITreeFunctionRegistry()
///
/// // Register using dot-separated string
/// registry.setFunction(path: "layer.node") { print("Hello from layer.node!") }
///
/// // Register using array of strings
/// registry.setFunction(path: ["layer", "otherNode"]) { print("Hello from layer.otherNode!") }
///
/// // Register using enums with String raw values
/// enum CLIPath: String { case layer, node }
/// registry.setFunction(path: [CLIPath.layer, CLIPath.node]) { print("Hello from enum path!") }
///
/// // Call functions
/// registry.callFunction(path: "layer.node") // Prints: Hello from layer.node!
/// registry.callFunction(path: ["layer", "otherNode"]) // Prints: Hello from layer.otherNode!
/// registry.callFunction(path: [CLIPath.layer, CLIPath.node]) // Prints: Hello from enum path!
/// ```
///
/// - Author: Your Name
public class CLITreeFunctionRegistry {
    private var functionDict: [String: Any] = [:]

    public init() {}

    // Accepts String, [String], or [RawRepresentable]
    private func normalizePath(_ path: Any) -> [String] {
        if let str = path as? String {
            return str.split(separator: ".").map { String($0) }
        } else if let arr = path as? [String] {
            return arr
        } else if let arr = path as? [any RawRepresentable] {
            return arr.compactMap {
                ($0.rawValue as? String)
            }
        }
        return []
    }

    public func setFunction(path: Any, function: @escaping CLIFunction) {
        let keys = normalizePath(path)
        guard !keys.isEmpty else { return }
        var dict = functionDict
        var stack: [[String: Any]] = []
        for (i, key) in keys.enumerated() {
            if i == keys.count - 1 {
                dict[key] = function
            } else {
                if dict[key] == nil || !(dict[key] is [String: Any]) {
                    dict[key] = [String: Any]()
                }
                stack.append(dict)
                dict = dict[key] as! [String: Any]
            }
        }
        for (i, key) in keys.dropLast().enumerated().reversed() {
            var prevDict = stack[i]
            prevDict[key] = dict
            dict = prevDict
        }
        functionDict = dict
    }

    public func callFunction(path: Any) {
        let keys = normalizePath(path)
        guard !keys.isEmpty else { return }
        var current: Any = functionDict
        for key in keys {
            if let dict = current as? [String: Any], let next = dict[key] {
                current = next
            } else if let function = current as? CLIFunction {
                function()
                return
            } else {
                print("Function not found for path: \(keys.joined(separator: "."))")
                return
            }
        }
        if let function = current as? CLIFunction {
            function()
        } else {
            print("Function not found for path: \(keys.joined(separator: "."))")
        }
    }
}
