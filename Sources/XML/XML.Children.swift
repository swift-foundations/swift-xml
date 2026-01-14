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
    /// Nested accessor for filtering children by name.
    public struct Named: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(_ xml: XML) {
            self.xml = xml
        }

        /// Child elements with the specified name.
        ///
        /// - Parameter name: The element name to filter by.
        /// - Returns: Array of matching child elements.
        @inlinable
        public subscript(_ name: String) -> [XML] {
            xml.raw.children(name).map(XML.init)
        }
    }

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
    /// Nested accessor for first child by name.
    public struct First: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(_ xml: XML) {
            self.xml = xml
        }

        /// First child element with the specified name.
        ///
        /// - Parameter name: The element name to find.
        /// - Returns: The first matching element, or `nil` if not found.
        @inlinable
        public subscript(_ name: String) -> XML? {
            xml.raw.child(name).map(XML.init)
        }
    }

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
    /// Nested accessor for descendants by name.
    public struct Descendants: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(_ xml: XML) {
            self.xml = xml
        }

        /// Descendant elements with the specified name (recursive).
        ///
        /// - Parameter name: The element name to filter by.
        /// - Returns: Array of matching descendant elements.
        @inlinable
        public subscript(_ name: String) -> [XML] {
            xml.raw.descendants(name).map(XML.init)
        }
    }

    /// Access descendants filtered by name.
    ///
    /// ```swift
    /// xml.children.descendants["item"]  // [XML]
    /// ```
    @inlinable
    public var descendants: Descendants {
        Descendants(xml)
    }

    /// Nested accessor for first descendant by name.
    public struct Descendant: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(_ xml: XML) {
            self.xml = xml
        }

        /// First descendant element with the specified name (recursive).
        ///
        /// - Parameter name: The element name to find.
        /// - Returns: The first matching descendant, or `nil` if not found.
        @inlinable
        public subscript(_ name: String) -> XML? {
            xml.raw.descendant(name).map(XML.init)
        }
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
