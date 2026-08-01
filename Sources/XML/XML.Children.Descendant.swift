extension XML.Children {
    /// Nested accessor for first descendant by name.
    public struct Descendant: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(_ xml: XML) {
            self.xml = xml
        }
    }
}

extension XML.Children.Descendant {
    /// First descendant element with the specified name (recursive).
    ///
    /// - Parameter name: The element name to find.
    /// - Returns: The first matching descendant, or `nil` if not found.
    @inlinable
    public subscript(_ name: String) -> XML? {
        xml.raw.descendant(name).map(XML.init)
    }
}
