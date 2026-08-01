extension XML.Children {
    /// Nested accessor for first child by name.
    public struct First: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(_ xml: XML) {
            self.xml = xml
        }
    }
}

extension XML.Children.First {
    /// First child element with the specified name.
    ///
    /// - Parameter name: The element name to find.
    /// - Returns: The first matching element, or `nil` if not found.
    @inlinable
    public subscript(_ name: String) -> XML? {
        xml.raw.child(name).map(XML.init)
    }
}
