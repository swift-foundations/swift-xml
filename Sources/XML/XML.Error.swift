extension XML {

    public enum Error: Swift.Error, Sendable, Hashable {

        case syntax(message: String, line: Int, column: Int)

        case encoding(String)

        case depth(limit: Int)

        case empty

        case elementNotFound(name: String)

        case attributeNotFound(name: String)

        case typeMismatch(expected: String, got: String)
    }
}

extension XML.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .syntax(let message, let line, let column):
            if line > 0 {
                return "XML syntax error at line \(line), column \(column): \(message)"
            }
            return "XML syntax error: \(message)"

        case .encoding(let message):
            return "XML encoding error: \(message)"

        case .depth(let limit):
            return "XML depth limit (\(limit)) exceeded"

        case .empty:
            return "Empty XML input"

        case .elementNotFound(let name):
            return "XML element '\(name)' not found"

        case .attributeNotFound(let name):
            return "XML attribute '\(name)' not found"

        case .typeMismatch(let expected, let got):
            return "XML type mismatch: expected \(expected), got \(got)"
        }
    }
}
