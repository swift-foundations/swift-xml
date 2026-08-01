extension XML.Children {
    /// Nested accessor for filtering children by name.
    public struct Named: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(_ xml: XML) {
            self.xml = xml
        }
    }
}

extension XML.Children.Named {
    /// Child elements with the specified name.
    ///
    /// - Parameter name: The element name to filter by.
    /// - Returns: Array of matching child elements.
    @inlinable
    public subscript(_ name: String) -> [XML] {
        xml.raw.children(name).map(XML.init)
    }
}
