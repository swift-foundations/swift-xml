import W3C_XML

/// Serialization access through the `serialize` accessor.
extension XML {
    public struct Serialize: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(xml: XML) {
            self.xml = xml
        }
    }
}

extension XML.Serialize {
    /// Serializes the element to a string.
    ///
    /// - Parameter pretty: Whether to format with indentation.
    /// - Returns: The XML string.
    @inlinable
    public func callAsFunction(pretty: Bool = false) -> String {
        let bytes = xml.raw.encode(options: W3C_XML.Options(prettyPrint: pretty))
        return String(decoding: bytes, as: UTF8.self)
    }

    /// Serializes the element to UTF-8 bytes.
    ///
    /// - Parameter pretty: Whether to format with indentation.
    /// - Returns: The UTF-8 encoded XML bytes.
    @inlinable
    public func bytes(pretty: Bool = false) -> [UInt8] {
        xml.raw.encode(options: W3C_XML.Options(prettyPrint: pretty))
    }
}
