/// Nested accessor for XML child element access.
///
/// Provides access to child elements with filtering variants.
///
/// ## Usage
///
/// ```swift
/// xml.items.children()              // [XML] - all children
/// xml.items.children.named["item"]  // [XML] - filtered by name
/// xml.items.children.first["item"]  // XML? - first match
/// ```
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

// MARK: - Primary Access (callAsFunction)

extension XML.Children {
    /// All child elements.
    ///
    /// - Returns: Array of all child elements.
    @inlinable
    public func callAsFunction() -> [XML] {
        xml.raw.children.map(XML.init)
    }
}

// MARK: - Named Children

extension XML.Children {
    /// Access children filtered by name.
    ///
    /// ```swift
    /// xml.children.named["item"]  // [XML]
    /// ```
    @inlinable
    public var named: Named {
        Named(xml)
    }
}

// MARK: - First Child

extension XML.Children {
    /// Access first child by name.
    ///
    /// ```swift
    /// xml.children.first["item"]  // XML?
    /// ```
    @inlinable
    public var first: First {
        First(xml)
    }
}

// MARK: - Descendants

extension XML.Children {
    /// Access descendants filtered by name.
    ///
    /// ```swift
    /// xml.children.descendants["item"]  // [XML]
    /// ```
    @inlinable
    public var descendants: Descendants {
        Descendants(xml)
    }

    /// Access first descendant by name.
    ///
    /// ```swift
    /// xml.children.descendant["item"]  // XML?
    /// ```
    @inlinable
    public var descendant: Descendant {
        Descendant(xml)
    }
}

// MARK: - Instance Accessor

extension XML {
    /// Access child elements.
    ///
    /// ```swift
    /// xml.items.children()               // [XML] - all children
    /// xml.items.children.named["item"]   // [XML] - filtered by name
    /// xml.items.children.first["item"]   // XML? - first match
    /// ```
    @inlinable
    public var children: Children {
        Children(self)
    }
}
