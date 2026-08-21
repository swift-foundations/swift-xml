extension XML.Children {

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

    @inlinable
    public subscript(_ name: String) -> [XML] {
        xml.raw.children(name).map(XML.init)
    }
}
