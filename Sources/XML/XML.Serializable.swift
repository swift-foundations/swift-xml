extension XML {

    public protocol Serializable: Sendable {

        static func serialize(_ value: Self) -> XML

        static func deserialize(_ xml: XML) throws(XML.Error) -> Self
    }
}

extension XML.Serializable {

    @inlinable
    public var xml: XML {
        Self.serialize(self)
    }

    @inlinable
    public init(xml: XML) throws(XML.Error) {
        self = try Self.deserialize(xml)
    }

    @inlinable
    public init(xmlString: String) throws(XML.Error) {
        let xml = try XML.fragment(xmlString)
        self = try Self.deserialize(xml)
    }

    @inlinable
    public init<Bytes>(xmlBytes: Bytes) throws(XML.Error)
    where Bytes: Swift.Collection<UInt8>, Bytes: Sendable {
        let doc = try XML.parse(xmlBytes)
        self = try Self.deserialize(doc.root)
    }

    @inlinable
    public func xmlString(pretty: Bool = false) -> String {
        xml.serialize(pretty: pretty)
    }

    @inlinable
    public func xmlBytes(pretty: Bool = false) -> [UInt8] {
        xml.serialize.bytes(pretty: pretty)
    }
}

extension String: XML.Serializable {
    @inlinable
    public static func serialize(_ value: String) -> XML {
        XML(W3C_XML.Element(name: "string", content: [.text(value)]))
    }

    @inlinable
    public static func deserialize(_ xml: XML) throws(XML.Error) -> String {
        String(xml)
    }
}

extension Int: XML.Serializable {
    @inlinable
    public static func serialize(_ value: Int) -> XML {
        XML(W3C_XML.Element(name: "integer", content: [.text(String(value))]))
    }

    @inlinable
    public static func deserialize(_ xml: XML) throws(XML.Error) -> Int {
        guard let value = Int(xml) else {
            throw .typeMismatch(expected: "integer", got: xml.text())
        }
        return value
    }
}

extension Double: XML.Serializable {
    @inlinable
    public static func serialize(_ value: Double) -> XML {
        XML(W3C_XML.Element(name: "real", content: [.text(String(value))]))
    }

    @inlinable
    public static func deserialize(_ xml: XML) throws(XML.Error) -> Double {
        guard let value = Double(xml) else {
            throw .typeMismatch(expected: "real", got: xml.text())
        }
        return value
    }
}

extension Bool: XML.Serializable {
    @inlinable
    public static func serialize(_ value: Bool) -> XML {
        XML(W3C_XML.Element(name: value ? "true" : "false"))
    }

    @inlinable
    public static func deserialize(_ xml: XML) throws(XML.Error) -> Bool {
        switch xml.element.name {
        case "true": return true
        case "false": return false

        default:

            if let value = Bool(xml) {
                return value
            }
            throw .typeMismatch(expected: "boolean", got: xml.element.name)
        }
    }
}

extension Optional: XML.Serializable where Wrapped: XML.Serializable {
    @inlinable
    public static func serialize(_ value: Wrapped?) -> XML {
        switch value {
        case .some(let wrapped):
            return Wrapped.serialize(wrapped)

        case .none:
            return XML(W3C_XML.Element(name: "null"))
        }
    }

    @inlinable
    public static func deserialize(_ xml: XML) throws(XML.Error) -> Wrapped? {
        if xml.element.name == "null" || xml.isNull {
            return nil
        }
        return try Wrapped.deserialize(xml)
    }
}

extension Array: XML.Serializable where Element: XML.Serializable {
    @inlinable
    public static func serialize(_ value: [Element]) -> XML {
        XML.element("array", children: value.map { Element.serialize($0) })
    }

    @inlinable
    public static func deserialize(_ xml: XML) throws(XML.Error) -> [Element] {
        let allChildren = xml.children()
        var result: [Element] = []
        result.reserveCapacity(allChildren.count)
        for child in allChildren {
            result.append(try Element.deserialize(child))
        }
        return result
    }
}
