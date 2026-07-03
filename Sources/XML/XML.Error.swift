/// XML.Error.swift
/// swift-xml
///
/// User-friendly XML error types

extension XML {
    /// XML parsing and processing errors.
    ///
    /// These errors provide user-friendly messages for common XML issues.
    public enum Error: Swift.Error, Sendable, Hashable {
        /// Syntax error in XML.
        case syntax(message: String, line: Int, column: Int)

        /// Encoding error.
        case encoding(String)

        /// Depth limit exceeded.
        case depth(limit: Int)

        /// Empty input.
        case empty

        /// Element not found.
        case elementNotFound(name: String)

        /// Attribute not found.
        case attributeNotFound(name: String)

        /// Type conversion error.
        case typeMismatch(expected: String, got: String)
    }
}

// MARK: - Error CustomStringConvertible

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
