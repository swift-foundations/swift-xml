extension XML.Children {

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

    @inlinable
    public subscript(_ name: String) -> [XML] {
        xml.raw.descendants(name).map(XML.init)
    }
}
