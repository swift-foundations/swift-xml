/// Nested accessor for XML attribute access.
///
/// Provides subscript-based access to element attributes.
///
/// ## Usage
///
/// ```swift
/// xml.user.attributes["id"]    // String?
/// xml.user.attributes.all      // [String: String]
/// ```
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

// MARK: - Subscript Access

extension XML.Attributes {
    /// Accesses an attribute by name.
    ///
    /// - Parameter name: The attribute name.
    /// - Returns: The attribute value, or `nil` if not found.
    @inlinable
    public subscript(_ name: String) -> String? {
        xml.raw.attribute(name)
    }
}

// MARK: - All Attributes

extension XML.Attributes {
    /// All attributes as a dictionary.
    @inlinable
    public var all: [String: String] {
        var dict: [String: String] = [:]
        for attr in xml.raw.attributes {
            dict[attr.name.qualified] = attr.value
        }
        return dict
    }
}

// MARK: - Instance Accessor

extension XML {
    /// Access element attributes.
    ///
    /// ```swift
    /// xml.user.attributes["id"]    // String?
    /// xml.user.attributes.all      // [String: String]
    /// ```
    @inlinable
    public var attributes: Attributes {
        Attributes(self)
    }
}
