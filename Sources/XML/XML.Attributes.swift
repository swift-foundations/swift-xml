extension XML {
    public struct Attributes: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(_ xml: XML) {
            self.xml = xml
        }
    }
}

extension XML.Attributes {

    @inlinable
    public subscript(_ name: String) -> String? {
        xml.raw.attribute(name)
    }
}

extension XML.Attributes {

    @inlinable
    public var all: [String: String] {
        var dict: [String: String] = [:]
        for attr in xml.raw.attributes {
            dict[attr.name.qualified] = attr.value
        }
        return dict
    }
}

extension XML {

    @inlinable
    public var attributes: Attributes {
        Attributes(self)
    }
}
