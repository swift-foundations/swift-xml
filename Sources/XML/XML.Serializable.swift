/// XML.Serializable.swift
/// swift-xml
///
/// XML serialization protocol

extension XML {
    /// A type that can be serialized to/from XML.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct Person: XML.Serializable {
    ///     var name: String
    ///     var age: Int
    ///
    ///     static func serialize(_ value: Person) -> XML {
    ///         XML.element("person", children: [
    ///             XML.element("name", text: value.name),
    ///             XML.element("age", text: String(value.age))
    ///         ])
    ///     }
    ///
    ///     static func deserialize(_ xml: XML) throws(XML.Error) -> Person {
    ///         guard let name = xml.query.child("name")?.get.text else {
    ///             throw .elementNotFound(name: "name")
    ///         }
    ///         guard let ageStr = xml.query.child("age")?.get.text,
    ///               let age = Int(ageStr) else {
    ///             throw .elementNotFound(name: "age")
    ///         }
    ///         return Person(name: name, age: age)
    ///     }
    /// }
    /// ```
    public protocol Serializable: Sendable {
        /// Serializes a value to XML.
        static func serialize(_ value: Self) -> XML

        /// Deserializes XML to a value.
        static func deserialize(_ xml: XML) throws(XML.Error) -> Self
    }
}

// MARK: - Serializable Convenience Methods

extension XML.Serializable {
    /// The XML representation of this value.
    @inlinable
    public var xml: XML {
        Self.serialize(self)
    }

    /// Creates a value from XML.
    @inlinable
    public init(xml: XML) throws(XML.Error) {
        self = try Self.deserialize(xml)
    }

    /// Creates a value from an XML string.
    @inlinable
    public init(xmlString: String) throws(XML.Error) {
        let xml = try XML.fragment(xmlString)
        self = try Self.deserialize(xml)
    }

    /// Creates a value from UTF-8 encoded XML bytes.
    @inlinable
    public init<Bytes>(xmlBytes: Bytes) throws(XML.Error)
    where Bytes: Collection<UInt8>, Bytes: Sendable {
        let doc = try XML.parse(xmlBytes)
        self = try Self.deserialize(doc.root)
    }

    /// Converts this value to an XML string.
    @inlinable
    public func xmlString(pretty: Bool = false) -> String {
        xml.serialize(pretty: pretty)
    }

    /// Converts this value to UTF-8 encoded XML bytes.
    @inlinable
    public func xmlBytes(pretty: Bool = false) -> [UInt8] {
        xml.serialize.bytes(pretty: pretty)
    }
}

// MARK: - String Conformance

extension String: XML.Serializable {
    @inlinable
    public static func serialize(_ value: String) -> XML {
        XML(W3C_XML.Element(name: "string", content: [.text(value)]))
    }

    @inlinable
    public static func deserialize(_ xml: XML) throws(XML.Error) -> String {
        guard let text = xml.get.text else {
            return ""
        }
        return text
    }
}

// MARK: - Int Conformance

extension Int: XML.Serializable {
    @inlinable
    public static func serialize(_ value: Int) -> XML {
        XML(W3C_XML.Element(name: "integer", content: [.text(String(value))]))
    }

    @inlinable
    public static func deserialize(_ xml: XML) throws(XML.Error) -> Int {
        guard let text = xml.get.text,
              let value = Int(text) else {
            throw .typeMismatch(expected: "integer", got: xml.get.text ?? "nil")
        }
        return value
    }
}

// MARK: - Double Conformance

extension Double: XML.Serializable {
    @inlinable
    public static func serialize(_ value: Double) -> XML {
        XML(W3C_XML.Element(name: "real", content: [.text(String(value))]))
    }

    @inlinable
    public static func deserialize(_ xml: XML) throws(XML.Error) -> Double {
        guard let text = xml.get.text,
              let value = Double(text) else {
            throw .typeMismatch(expected: "real", got: xml.get.text ?? "nil")
        }
        return value
    }
}

// MARK: - Bool Conformance

extension Bool: XML.Serializable {
    @inlinable
    public static func serialize(_ value: Bool) -> XML {
        XML(W3C_XML.Element(name: value ? "true" : "false"))
    }

    @inlinable
    public static func deserialize(_ xml: XML) throws(XML.Error) -> Bool {
        let name = xml.get.name
        switch name {
        case "true": return true
        case "false": return false
        default:
            // Also check text content
            if let text = xml.get.text?.lowercased() {
                switch text {
                case "true", "yes", "1": return true
                case "false", "no", "0": return false
                default: break
                }
            }
            throw .typeMismatch(expected: "boolean", got: name)
        }
    }
}

// MARK: - Optional Conformance

extension Optional: XML.Serializable where Wrapped: XML.Serializable {
    @inlinable
    public static func serialize(_ value: Optional<Wrapped>) -> XML {
        switch value {
        case .some(let wrapped):
            return Wrapped.serialize(wrapped)
        case .none:
            return XML(W3C_XML.Element(name: "null"))
        }
    }

    @inlinable
    public static func deserialize(_ xml: XML) throws(XML.Error) -> Optional<Wrapped> {
        if xml.get.name == "null" || xml.isNull {
            return nil
        }
        return try Wrapped.deserialize(xml)
    }
}

// MARK: - Array Conformance

extension Array: XML.Serializable where Element: XML.Serializable {
    @inlinable
    public static func serialize(_ value: Array<Element>) -> XML {
        XML.element("array", children: value.map { Element.serialize($0) })
    }

    @inlinable
    public static func deserialize(_ xml: XML) throws(XML.Error) -> Array<Element> {
        var result: [Element] = []
        result.reserveCapacity(xml.get.children.count)
        for child in xml.get.children {
            result.append(try Element.deserialize(child))
        }
        return result
    }
}
