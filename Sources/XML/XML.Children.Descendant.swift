extension XML.Children {

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

    @inlinable
    public subscript(_ name: String) -> XML? {
        xml.raw.descendant(name).map(XML.init)
    }
}
