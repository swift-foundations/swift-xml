import W3C_XML

/// Serialization access through the `serialize` accessor.
extension XML.Document {
    public struct Serialize: Sendable {
        @usableFromInline
        let document: XML.Document

        @usableFromInline
        init(document: XML.Document) {
            self.document = document
        }
    }
}

extension XML.Document.Serialize {
    /// Serializes the document to a string.
    ///
    /// - Parameter pretty: Whether to format with indentation.
    /// - Returns: The XML string.
    @inlinable
    public func callAsFunction(pretty: Bool = false) -> String {
        let bytes = document.raw.encode(options: W3C_XML.Options(prettyPrint: pretty))
        return String(decoding: bytes, as: UTF8.self)
    }

    /// Serializes the document to UTF-8 bytes.
    ///
    /// - Parameter pretty: Whether to format with indentation.
    /// - Returns: The UTF-8 encoded XML bytes.
    @inlinable
    public func bytes(pretty: Bool = false) -> [UInt8] {
        document.raw.encode(options: W3C_XML.Options(prettyPrint: pretty))
    }
}
