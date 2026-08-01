import W3C_XML

/// A thread-safe, prepared XML parser.
///
/// `Prepared` is `Sendable` and can be safely shared across concurrent
/// tasks. It uses W3C_XML's Machine-based parser for stack-safe parsing
/// of deeply nested documents.
///
/// Create one using `XML.parse.prepared()`.
///
/// ## Concurrency Safety
///
/// ```swift
/// let parser = XML.parse.prepared()
///
/// // Safe: Prepared is Sendable
/// await withTaskGroup(of: XML.Document.self) { group in
///     for data in documents {
///         group.addTask { try parser.parse(data) }
///     }
/// }
/// ```
extension XML {
    public struct Prepared: Sendable {
        /// Maximum nesting depth.
        public let maxDepth: Int

        @usableFromInline
        internal init(maxDepth: Int) {
            self.maxDepth = maxDepth
        }
    }
}

extension XML.Prepared {
    /// Parses an XML document from a string.
    ///
    /// - Parameter string: The XML string to parse.
    /// - Returns: The parsed document.
    /// - Throws: `XML.Error` if parsing fails.
    @inlinable
    public func parse(_ string: String) throws(XML.Error) -> XML.Document {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(string, maxDepth: maxDepth)
            return XML.Document(doc)
        } catch {
            throw XML.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }

    /// Parses an XML document from UTF-8 bytes.
    ///
    /// - Parameter bytes: The UTF-8 encoded XML bytes.
    /// - Returns: The parsed document.
    /// - Throws: `XML.Error` if parsing fails.
    @inlinable
    public func parse<Bytes>(_ bytes: Bytes) throws(XML.Error) -> XML.Document
    where Bytes: Swift.Collection<UInt8>, Bytes: Sendable {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(bytes, maxDepth: maxDepth)
            return XML.Document(doc)
        } catch {
            throw XML.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }

    /// Parses an XML fragment (single element).
    ///
    /// - Parameter string: The XML fragment string.
    /// - Returns: The parsed element.
    /// - Throws: `XML.Error` if parsing fails.
    @inlinable
    public func fragment(_ string: String) throws(XML.Error) -> XML {
        do {
            let element = try W3C_XML.fragment(string)
            return XML(element)
        } catch {
            throw XML.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }
}
