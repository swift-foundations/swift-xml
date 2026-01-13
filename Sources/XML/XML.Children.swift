/// Nested accessor for XML child element access.
///
/// Provides access to child elements with filtering variants.
///
/// ## Usage
///
/// ```swift
/// xml.items.children()              // [XML] - all children
/// xml.items.children.named("item")  // [XML] - filtered by name
/// xml.items.children.first("item")  // XML? - first match
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
    /// Child elements with the specified name.
    ///
    /// - Parameter name: The element name to filter by.
    /// - Returns: Array of matching child elements.
    @inlinable
    public func named(_ name: String) -> [XML] {
        xml.raw.children(name).map(XML.init)
    }
}

// MARK: - First Child

extension XML.Children {
    /// First child element with the specified name.
    ///
    /// - Parameter name: The element name to find.
    /// - Returns: The first matching element, or `nil` if not found.
    @inlinable
    public func first(_ name: String) -> XML? {
        xml.raw.child(name).map(XML.init)
    }
}

// MARK: - Descendants

extension XML.Children {
    /// All descendant elements (recursive).
    ///
    /// - Returns: Array of all descendant elements.
    @inlinable
    public var descendants: [XML] {
        xml.raw.descendants.map(XML.init)
    }

    /// Descendant elements with the specified name (recursive).
    ///
    /// - Parameter name: The element name to filter by.
    /// - Returns: Array of matching descendant elements.
    @inlinable
    public func descendants(_ name: String) -> [XML] {
        xml.raw.descendants(name).map(XML.init)
    }

    /// First descendant element with the specified name (recursive).
    ///
    /// - Parameter name: The element name to find.
    /// - Returns: The first matching descendant, or `nil` if not found.
    @inlinable
    public func descendant(_ name: String) -> XML? {
        xml.raw.descendant(name).map(XML.init)
    }
}

// MARK: - Instance Accessor

extension XML {
    /// Access child elements.
    ///
    /// ```swift
    /// xml.items.children()              // [XML] - all children
    /// xml.items.children.named("item")  // [XML] - filtered by name
    /// xml.items.children.first("item")  // XML? - first match
    /// ```
    @inlinable
    public var children: Children {
        Children(self)
    }
}
