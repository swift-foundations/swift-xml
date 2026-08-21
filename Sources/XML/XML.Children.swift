extension XML {
    public struct Children: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(_ xml: XML) {
            self.xml = xml
        }
    }
}

extension XML.Children {

    @inlinable
    public func callAsFunction() -> [XML] {
        xml.raw.children.map(XML.init)
    }
}

extension XML.Children {

    @inlinable
    public var named: Named {
        Named(xml)
    }
}

extension XML.Children {

    @inlinable
    public var first: First {
        First(xml)
    }
}

extension XML.Children {

    @inlinable
    public var descendants: Descendants {
        Descendants(xml)
    }

    @inlinable
    public var descendant: Descendant {
        Descendant(xml)
    }
}

extension XML {

    @inlinable
    public var children: Children {
        Children(self)
    }
}
