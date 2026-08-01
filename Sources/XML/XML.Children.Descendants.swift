extension XML.Children {
    /// Nested accessor for descendants by name.
    public struct Descendants: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(_ xml: XML) {
            self.xml = xml
        }
    }
}

extension XML.Children.Descendants {
    /// Descendant elements with the specified name (recursive).
    ///
    /// - Parameter name: The element name to filter by.
    /// - Returns: Array of matching descendant elements.
    @inlinable
    public subscript(_ name: String) -> [XML] {
        xml.raw.descendants(name).map(XML.init)
    }
}
