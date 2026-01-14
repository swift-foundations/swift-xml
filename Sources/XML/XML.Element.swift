/// Nested accessor for XML element metadata.
///
/// Provides access to element name, qualified name, and prefix.
///
/// ## Usage
///
/// ```swift
/// xml.element.name       // "item"
/// xml.element.qualified  // "ex:item"
/// xml.element.prefix     // "ex"
/// ```
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

// MARK: - Element Metadata

extension XML.Element {
    /// Element name (local part only).
    @inlinable
    public var name: String {
        xml.raw.name.local
    }

    /// Qualified element name (prefix:local).
    @inlinable
    public var qualified: String {
        xml.raw.name.qualified
    }

    /// Namespace prefix, if any.
    @inlinable
    public var prefix: String? {
        xml.raw.name.prefix
    }
}

// MARK: - Instance Accessor

extension XML {
    /// Access element metadata.
    ///
    /// ```swift
    /// xml.element.name       // Element name
    /// xml.element.qualified  // Qualified name
    /// xml.element.prefix     // Namespace prefix
    /// ```
    @inlinable
    public var element: Element {
        Element(self)
    }
}
