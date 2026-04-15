/// XML.Stream.swift
/// swift-xml
///
/// Async XML streaming support

import W3C_XML
import Async

// MARK: - Async Parse

extension XML {
    /// Parses XML from an async byte sequence.
    ///
    /// This collects all bytes before parsing (buffered approach).
    /// For very large documents, consider streaming parsers.
    ///
    /// - Parameter bytes: The async sequence of bytes.
    /// - Returns: The parsed document.
    /// - Throws: `XML.Error` if parsing fails.
    @inlinable
    public static func parse<S: AsyncSequence & Sendable>(
        collecting bytes: S
    ) async throws(XML.Error) -> XML.Document
    where S.Element == UInt8 {
        var buffer: [UInt8] = []
        do {
            for try await byte in bytes {
                buffer.append(byte)
            }
        } catch {
            throw .syntax(message: "Error reading bytes: \(error)", line: 0, column: 0)
        }
        return try parse(buffer)
    }
}

// MARK: - Parse Accessor Async Extension

extension XML.Parse {
    /// Parses XML from an async byte sequence.
    ///
    /// Collects all bytes before parsing.
    ///
    /// - Parameter bytes: The async sequence of bytes.
    /// - Returns: The parsed document.
    /// - Throws: `XML.Error` if parsing fails.
    @inlinable
    public func collecting<S: AsyncSequence & Sendable>(
        _ bytes: S
    ) async throws(XML.Error) -> XML.Document
    where S.Element == UInt8 {
        try await XML.parse(collecting: bytes)
    }
}

// MARK: - Serializable Async Support

extension XML.Serializable {
    /// Creates a value from async XML bytes.
    @inlinable
    public init<S: AsyncSequence & Sendable>(
        collecting bytes: S
    ) async throws(XML.Error)
    where S.Element == UInt8 {
        let doc = try await XML.parse(collecting: bytes)
        self = try Self.deserialize(doc.root)
    }
}

// MARK: - Newline-Delimited XML Streaming

extension XML {
    /// Namespace for newline-delimited (ND) XML operations.
    ///
    /// ND XML is a streaming format where each line contains a complete
    /// XML document. This enables processing large streams of XML data
    /// with minimal memory usage.
    ///
    /// ## Format
    ///
    /// Each line is a complete XML document, separated by newlines:
    /// ```
    /// <?xml version="1.0"?><root><value>1</value></root>
    /// <?xml version="1.0"?><root><value>2</value></root>
    /// ```
    ///
    /// ## Limitations
    ///
    /// - Each document must be on a single line (no embedded newlines)
    /// - Best suited for simple/flat XML structures
    ///
    /// ## Example
    ///
    /// ```swift
    /// for await result in XML.ND.stream(bytes) {
    ///     switch result {
    ///     case .success(let doc):
    ///         process(doc)
    ///     case .failure(let error):
    ///         log(error)  // Stream continues after errors
    ///     }
    /// }
    /// ```
    public enum ND: Sendable {}
}

extension XML.ND {
    /// Streams XML documents from newline-delimited input.
    ///
    /// Parses each line as a complete XML document. Empty lines are skipped.
    /// Errors on individual lines are returned as `.failure` results,
    /// allowing the stream to continue processing subsequent lines.
    ///
    /// - Parameter bytes: Async sequence of input bytes.
    /// - Returns: Stream of parse results (success or failure per line).
    @inlinable
    public static func stream<S: AsyncSequence & Sendable>(
        _ bytes: S
    ) -> Async.Stream<Result<XML.Document, XML.Error>>
    where S.Element == UInt8 {
        Async.Stream {
            let state = State(bytes.makeAsyncIterator())
            return Async.Stream<Result<XML.Document, XML.Error>>.Iterator {
                await state.next()
            }
        }
    }
}

extension XML.ND {
    /// Internal state machine for ND XML parsing.
    // WHY: Category D — structural Sendable workaround.
    // WHY: AsyncIteratorProtocol generic parameter blocks Sendable inference.
    // WHY: No caller invariant to uphold — data is structurally safe.
    // WHEN TO REMOVE: When compiler gains structural Sendable inference through
    // WHEN TO REMOVE: AsyncIteratorProtocol generic parameters.
    // TRACKING: unsafe-audit-findings.md Category D; SP-4.
    @usableFromInline
    internal final class State<I: AsyncIteratorProtocol>: @unchecked Sendable
    where I.Element == UInt8 {
        @usableFromInline
        var iterator: I

        @usableFromInline
        var buffer: [UInt8] = []

        @usableFromInline
        var done = false

        @usableFromInline
        init(_ iterator: I) {
            self.iterator = iterator
        }

        @usableFromInline
        func next() async -> Result<XML.Document, XML.Error>? {
            if done { return nil }

            while true {
                let byte: UInt8?
                do {
                    byte = try await iterator.next()
                } catch {
                    done = true
                    if buffer.isEmpty { return nil }
                    defer { buffer.removeAll() }
                    return parseLine()
                }

                guard let byte else {
                    // End of input
                    done = true
                    if buffer.isEmpty { return nil }
                    defer { buffer.removeAll() }
                    return parseLine()
                }

                if byte == 0x0A { // LF - newline
                    if buffer.isEmpty { continue } // Skip empty lines
                    defer { buffer.removeAll(keepingCapacity: true) }
                    return parseLine()
                }

                if byte == 0x0D { continue } // Skip CR

                buffer.append(byte)
            }
        }

        @usableFromInline
        func parseLine() -> Result<XML.Document, XML.Error> {
            do {
                let doc = try XML.parse(buffer)
                return .success(doc)
            } catch {
                return .failure(error)
            }
        }
    }
}

// MARK: - Parse Accessor ND Extension

extension XML.Parse {
    /// Streams XML documents from newline-delimited input.
    ///
    /// Each line is parsed as a complete XML document. Empty lines are skipped.
    /// Errors on individual lines are returned as `.failure` results.
    ///
    /// - Parameter bytes: Async sequence of input bytes.
    /// - Returns: Stream of parse results.
    @inlinable
    public func stream<S: AsyncSequence & Sendable>(
        nd bytes: S
    ) -> Async.Stream<Result<XML.Document, XML.Error>>
    where S.Element == UInt8 {
        XML.ND.stream(bytes)
    }
}
