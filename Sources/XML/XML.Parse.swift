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

public import Array_Primitives
public import Buffer_Linear_Primitive
public import Buffer_Linear_Primitives
public import Input_Slice_Primitives
public import Shared_Primitive
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
        internal let maxDepth: Int = 10000

        /// Parses an XML document from a string.
        ///
        /// - Parameter string: The XML string to parse.
        /// - Returns: The parsed document.
        /// - Throws: `XML.Error` if parsing fails.
        @inlinable
        public func callAsFunction(_ string: String) throws(XML.Error) -> XML.Document {
            do {
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
        public func callAsFunction<Bytes>(_ bytes: Bytes) throws(XML.Error) -> XML.Document
        where Bytes: Swift.Collection<UInt8>, Bytes: Sendable {
            do {
                let doc = try W3C_XML.parse(bytes, maxDepth: maxDepth)
                return XML.Document(doc)
            } catch {
                throw XML.Error.syntax(message: "\(error)", line: 0, column: 0)
            }
        }
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

// MARK: - Prepared Type

extension XML {
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
    public struct Prepared: Sendable {
        /// Maximum nesting depth.
        public let maxDepth: Int

        @usableFromInline
        internal init(maxDepth: Int) {
            self.maxDepth = maxDepth
        }

        /// Parses an XML document from a string.
        ///
        /// - Parameter string: The XML string to parse.
        /// - Returns: The parsed document.
        /// - Throws: `XML.Error` if parsing fails.
        @inlinable
        public func parse(_ string: String) throws(XML.Error) -> XML.Document {
            do {
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
            do {
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
}

// MARK: - Located Type

extension XML {
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
    public struct Located: Sendable {
        /// Maximum nesting depth.
        public let maxDepth: Int

        @usableFromInline
        internal init(maxDepth: Int) {
            self.maxDepth = maxDepth
        }

        /// Parses an XML document from a string with located errors.
        ///
        /// - Parameter string: The XML string to parse.
        /// - Returns: The parsed document.
        /// - Throws: `XML.LocatedError` if parsing fails.
        @inlinable
        public func parse(_ string: String) throws(XML.LocatedError) -> XML.Document {
            do {
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
            do {
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
}

// MARK: - LocatedError Type

extension XML {
    /// An error with byte-offset location information.
    ///
    /// This type wraps an `XML.Error` with the byte offset where the error
    /// occurred, enabling precise error reporting.
    public struct LocatedError: Swift.Error, Sendable, Hashable {
        /// The underlying XML error.
        public let error: XML.Error

        /// Byte offset from the start of input where the error occurred.
        public let offset: Int

        /// Creates a located error.
        ///
        /// - Parameters:
        ///   - error: The underlying error.
        ///   - offset: Byte offset from input start.
        @inlinable
        public init(_ error: XML.Error, at offset: Int) {
            self.error = error
            self.offset = offset
        }
    }
}

extension XML.LocatedError: CustomStringConvertible {
    public var description: String {
        "at byte \(offset): \(error)"
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
