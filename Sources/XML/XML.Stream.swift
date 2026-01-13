/// XML.Stream.swift
/// swift-xml
///
/// Async XML streaming support

import W3C_XML
import Async

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
