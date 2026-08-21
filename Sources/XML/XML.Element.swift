extension XML {
    public struct Element: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(_ xml: XML) {
            self.xml = xml
        }
    }
}

extension XML.Element {

    @inlinable
    public var name: String {
        xml.raw.name.local
    }

    @inlinable
    public var qualified: String {
        xml.raw.name.qualified
    }

    @inlinable
    public var prefix: String? {
        xml.raw.name.prefix
    }
}

extension XML {

    @inlinable
    public var element: Element {
        Element(self)
    }
}
