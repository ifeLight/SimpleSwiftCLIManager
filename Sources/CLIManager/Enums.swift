import ArgumentParser

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
