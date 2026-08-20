/// XML.Parse.swift
/// swift-xml
///
/// Parse accessor pattern for XML parsing with compilation support.
///
/// This module provides the nested accessor pattern for XML parsing,
/// enabling discoverable access to different execution strategies:
///
/// ```swift
/// // Direct parsing (existing API)
/// let doc = try XML.parse(string)
///
/// // Parse accessor pattern
/// let prepared = XML.parse.prepared()
/// let doc = try prepared.parse(string)
/// ```
///
/// ## Machine-Based Stack Safety
///
/// The W3C_XML parser uses `Parsing.Machine` for stack-safe recursive
/// parsing. This enables parsing of deeply nested documents (up to
/// 10,000 levels by default) without stack overflow.

internal import Array_Primitives
internal import Buffer_Linear_Primitive
internal import Buffer_Linear_Primitives
internal import Input_Slice_Primitives
internal import Ownership_Shared_Primitive
import W3C_XML

// MARK: - Parse Accessor

extension XML {
    /// Accessor providing parse operation variants.
    ///
    /// The `Parse` struct encapsulates execution strategies for XML parsing,
    /// enabling discoverability via autocomplete:
    ///
    /// ```swift
    /// XML.parse.
    ///         ├── prepared()   // Prepared parser, thread-safe
    ///         ├── located()    // Parse with byte-offset error tracking
    ///         └── callAsFunction()  // Direct parse (default)
    /// ```
    public struct Parse: Sendable {
        @usableFromInline
        internal init() {}

        /// Default maximum nesting depth.
        @usableFromInline
        internal let depth: Int = 10000
    }

    /// Accessor for parse operation variants.
    ///
    /// Use this to discover and access different execution strategies:
    /// - `parse.prepared()` — thread-safe prepared parser
    /// - `parse.located()` — parse with byte-offset error tracking
    /// - `parse(string)` — direct parse (shorthand)
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a prepared parser for batch document processing
    /// let parser = XML.parse.prepared()
    ///
    /// // Parse multiple documents concurrently
    /// await withTaskGroup(of: XML.Document.self) { group in
    ///     for data in documents {
    ///         group.addTask { try parser.parse(data) }
    ///     }
    /// }
    /// ```
    public static var parse: Parse { Parse() }
}

extension XML.Parse {
    /// Parses an XML document from a string.
    ///
    /// - Parameter string: The XML string to parse.
    /// - Returns: The parsed document.
    /// - Throws: `XML.Error` if parsing fails.
    @inlinable
    public func callAsFunction(_ string: String) throws(XML.Error) -> XML.Document {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(string, maxDepth: depth)
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
    public func callAsFunction<Bytes>(_ bytes: Bytes) throws(XML.Error) -> XML.Document
    where Bytes: Swift.Collection<UInt8>, Bytes: Sendable {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(bytes, maxDepth: depth)
            return XML.Document(doc)
        } catch {
            throw XML.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }
}

// MARK: - Prepared Parser

extension XML.Parse {
    /// Creates an eagerly-prepared, thread-safe parser.
    ///
    /// The returned parser is `Sendable` and can be safely shared across
    /// concurrent tasks. It uses W3C_XML's Machine-based stack-safe parsing.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let parser = XML.parse.prepared()
    ///
    /// // Safe to use from multiple tasks
    /// Task { try parser.parse(data1) }
    /// Task { try parser.parse(data2) }
    /// ```
    ///
    /// - Parameter maxDepth: Maximum nesting depth (default: 10000).
    /// - Returns: A thread-safe prepared parser.
    @inlinable
    public func prepared(maxDepth: Int = 10000) -> XML.Prepared {
        XML.Prepared(maxDepth: maxDepth)
    }
}

// MARK: - Located Parsing

extension XML.Parse {
    /// Creates a parser that tracks byte offsets in errors.
    ///
    /// The returned parser produces errors with byte offset information,
    /// enabling precise error reporting for diagnostics.
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
    ///
    /// - Parameter maxDepth: Maximum nesting depth (default: 10000).
    /// - Returns: A parser that produces located errors.
    @inlinable
    public func located(maxDepth: Int = 10000) -> XML.Located {
        XML.Located(maxDepth: maxDepth)
    }
}

// MARK: - Fragment Parsing

extension XML.Parse {
    /// Parses an XML fragment (single element, no document wrapper).
    ///
    /// - Parameter string: The XML fragment string to parse.
    /// - Returns: The parsed element.
    /// - Throws: `XML.Error` if parsing fails.
    @inlinable
    public func fragment(_ string: String) throws(XML.Error) -> XML {
        try XML.fragment(string)
    }
}
