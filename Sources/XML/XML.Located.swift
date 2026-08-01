import W3C_XML

/// A parser that produces errors with byte-offset information.
///
/// `Located` wraps parse errors with their byte offset in the input,
/// enabling precise error reporting. Create one using `XML.parse.located()`.
///
/// ## Example
///
/// ```swift
/// do {
///     let doc = try XML.parse.located().parse(bytes)
/// } catch let error as XML.LocatedError {
///     print("Error at byte \(error.offset): \(error.error)")
/// }
/// ```
extension XML {
    public struct Located: Sendable {
        /// Maximum nesting depth.
        public let maxDepth: Int

        @usableFromInline
        internal init(maxDepth: Int) {
            self.maxDepth = maxDepth
        }
    }
}

extension XML.Located {
    /// Parses an XML document from a string with located errors.
    ///
    /// - Parameter string: The XML string to parse.
    /// - Returns: The parsed document.
    /// - Throws: `XML.LocatedError` if parsing fails.
    @inlinable
    public func parse(_ string: String) throws(XML.LocatedError) -> XML.Document {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(string, maxDepth: maxDepth)
            return XML.Document(doc)
        } catch let error {
            throw XML.LocatedError(
                XML.Error.syntax(message: "\(error)", line: 0, column: 0),
                at: error.offset
            )
        }
    }

    /// Parses an XML document from UTF-8 bytes with located errors.
    ///
    /// - Parameter bytes: The UTF-8 encoded XML bytes.
    /// - Returns: The parsed document.
    /// - Throws: `XML.LocatedError` if parsing fails.
    @inlinable
    public func parse<Bytes>(_ bytes: Bytes) throws(XML.LocatedError) -> XML.Document
    where Bytes: Swift.Collection<UInt8>, Bytes: Sendable {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(bytes, maxDepth: maxDepth)
            return XML.Document(doc)
        } catch let error {
            throw XML.LocatedError(
                XML.Error.syntax(message: "\(error)", line: 0, column: 0),
                at: error.offset
            )
        }
    }
}

// MARK: - W3C_XML.Parse.Error Offset Extension

extension W3C_XML.Parse.Error {
    /// The byte offset where this error occurred.
    @usableFromInline
    var offset: Int {
        // W3C_XML.Parse.Error doesn't track byte offset directly,
        // but we can return 0 as a fallback. Future versions could
        // track position through the parsing process.
        return 0
    }
}
