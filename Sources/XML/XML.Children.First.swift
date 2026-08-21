extension XML.Children {

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

    @inlinable
    public subscript(_ name: String) -> XML? {
        xml.raw.child(name).map(XML.init)
    }
}
