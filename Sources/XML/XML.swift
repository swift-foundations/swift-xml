/// XML
/// swift-xml
///
/// A modern, type-safe XML API for Swift 6.2+
///
/// ## Overview
///
/// `XML` is both a namespace and a value type, providing an ergonomic API
/// for working with XML data in Swift.
///
/// ## Construction
///
/// ```swift
/// // Via parsing
/// let doc = try XML.parse(xmlString)
/// let xml = doc.root
///
/// // Via fragment
/// let xml = try XML.fragment("<item>Hello</item>")
/// ```
///
/// ## Access
///
/// ```swift
/// // Dynamic member lookup
/// xml.item.get.text        // Optional("Hello")
/// xml.item.get.attribute("id")  // Optional("123")
///
/// // Subscript access
/// xml["item"].get.text
/// xml["items"][0].get.name
/// ```
///
/// ## Serialization
///
/// ```swift
/// let string = xml.serialize()
/// let pretty = xml.serialize(pretty: true)
/// ```

import W3C_XML

/// An XML element for ergonomic access.
///
/// `XML` wraps `W3C_XML.Element` and provides type-safe access and
/// ergonomic APIs for working with XML data.
@dynamicMemberLookup
public struct XML: Sendable, Hashable {
    /// The underlying W3C_XML element.
    @usableFromInline
    internal var raw: W3C_XML.Element

    /// Creates an XML value from a W3C_XML element.
    @inlinable
    public init(_ raw: W3C_XML.Element) {
        self.raw = raw
    }
}

// MARK: - Static Constructors

extension XML {
    /// Creates an empty XML element with the given name.
    @inlinable
    public static func element(_ name: String) -> XML {
        XML(W3C_XML.Element(name: name))
    }

    /// Creates an XML element with text content.
    @inlinable
    public static func element(_ name: String, text: String) -> XML {
        XML(W3C_XML.Element(
            name: name,
            content: [.text(text)]
        ))
    }

    /// Creates an XML element with children.
    @inlinable
    public static func element(_ name: String, children: [XML]) -> XML {
        XML(W3C_XML.Element(
            name: name,
            content: children.map { .element($0.raw) }
        ))
    }
}

// MARK: - Type Checking

extension XML {
    /// Returns `true` if this element has text content.
    @inlinable
    public var isText: Bool {
        !raw.textContent.isEmpty
    }

    /// Returns `true` if this element has no content.
    @inlinable
    public var isEmpty: Bool {
        raw.content.isEmpty
    }

    /// Returns `true` if this element has child elements.
    @inlinable
    public var isParent: Bool {
        raw.children.count > 0
    }
}

// MARK: - Get Accessor

extension XML {
    /// Value access through the `get` accessor.
    public struct Get: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(xml: XML) {
            self.xml = xml
        }

        /// Element name (local part).
        @inlinable
        public var name: String {
            xml.raw.name.local
        }

        /// Qualified name (prefix:local).
        @inlinable
        public var qualified: String {
            xml.raw.name.qualified
        }

        /// Namespace prefix.
        @inlinable
        public var prefix: String? {
            xml.raw.name.prefix
        }

        /// Text content (direct text only).
        @inlinable
        public var text: String? {
            let t = xml.raw.textContent
            return t.isEmpty ? nil : t
        }

        /// All text content including nested elements.
        @inlinable
        public var allText: String {
            collectAllText(xml.raw)
        }

        /// Child elements.
        @inlinable
        public var children: [XML] {
            xml.raw.children.map(XML.init)
        }

        /// Attributes as dictionary.
        @inlinable
        public var attributes: [String: String] {
            var dict: [String: String] = [:]
            for attr in xml.raw.attributes {
                dict[attr.name.qualified] = attr.value
            }
            return dict
        }

        /// Gets a specific attribute by name.
        @inlinable
        public func attribute(_ name: String) -> String? {
            xml.raw.attribute(name)
        }

        /// Collects all text from an element and its descendants.
        @usableFromInline
        internal func collectAllText(_ element: W3C_XML.Element) -> String {
            var result = ""
            for content in element.content {
                switch content {
                case .text(let t):
                    result += t
                case .cdata(let c):
                    result += c
                case .element(let e):
                    result += collectAllText(e)
                default:
                    break
                }
            }
            return result
        }
    }

    /// Access element properties through the `get` accessor.
    @inlinable
    public var get: Get {
        Get(xml: self)
    }
}

// MARK: - Query Accessor

extension XML {
    /// Query access through the `query` accessor.
    public struct Query: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(xml: XML) {
            self.xml = xml
        }

        /// Finds the first child element by name.
        @inlinable
        public func child(_ name: String) -> XML? {
            xml.raw.child(name).map(XML.init)
        }

        /// Finds all child elements by name.
        @inlinable
        public func children(_ name: String) -> [XML] {
            xml.raw.children(name).map(XML.init)
        }

        /// Finds the first descendant by name.
        @inlinable
        public func descendant(_ name: String) -> XML? {
            xml.raw.descendant(name).map(XML.init)
        }

        /// Finds all descendants by name.
        @inlinable
        public func descendants(_ name: String) -> [XML] {
            xml.raw.descendants(name).map(XML.init)
        }

        /// Finds elements matching a predicate.
        @inlinable
        public func filter(_ predicate: (XML) -> Bool) -> [XML] {
            xml.get.children.filter(predicate)
        }
    }

    /// Query element structure through the `query` accessor.
    @inlinable
    public var query: Query {
        Query(xml: self)
    }
}

// MARK: - Subscripts

extension XML {
    /// Accesses the first child element with the given name.
    ///
    /// Returns an empty XML element if not found (allows safe chaining).
    @inlinable
    public subscript(name: String) -> XML {
        query.child(name) ?? XML(W3C_XML.Element(name: "_null"))
    }

    /// Accesses a child element by index.
    ///
    /// Returns an empty XML element if out of bounds.
    @inlinable
    public subscript(index: Int) -> XML {
        let children = get.children
        guard index >= 0 && index < children.count else {
            return XML(W3C_XML.Element(name: "_null"))
        }
        return children[index]
    }
}

// MARK: - Dynamic Member Lookup

extension XML {
    /// Accesses a child element by name using dot notation.
    ///
    /// Enables `xml.item` syntax instead of `xml["item"]`.
    @inlinable
    public subscript(dynamicMember member: String) -> XML {
        self[member]
    }
}

// MARK: - Null Check

extension XML {
    /// Returns `true` if this is a null/empty placeholder element.
    ///
    /// Used for safe chaining - operations on null elements return null.
    @inlinable
    public var isNull: Bool {
        raw.name.local == "_null"
    }

    /// Returns this element if not null, otherwise returns nil.
    @inlinable
    public var optional: XML? {
        isNull ? nil : self
    }
}

// MARK: - Parsing

extension XML {
    /// Parses an XML document.
    ///
    /// - Parameter string: The XML string to parse.
    /// - Returns: The parsed document.
    /// - Throws: `XML.Error` if parsing fails.
    @inlinable
    public static func parse(_ string: String) throws(XML.Error) -> XML.Document {
        do {
            let doc = try W3C_XML.parse(string)
            return XML.Document(doc)
        } catch {
            throw XML.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }

    /// Parses an XML document from UTF-8 bytes.
    ///
    /// - Parameter bytes: The UTF-8 encoded XML bytes.
    /// - Returns: The parsed document.
    /// - Throws: `XML.Error` if parsing fails.
    @inlinable
    public static func parse<Bytes>(_ bytes: Bytes) throws(XML.Error) -> XML.Document
    where Bytes: Collection<UInt8>, Bytes: Sendable {
        do {
            let doc = try W3C_XML.parse(bytes)
            return XML.Document(doc)
        } catch {
            throw XML.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }

    /// Parses an XML fragment (single element).
    ///
    /// - Parameter string: The XML fragment string to parse.
    /// - Returns: The parsed element.
    /// - Throws: `XML.Error` if parsing fails.
    @inlinable
    public static func fragment(_ string: String) throws(XML.Error) -> XML {
        do {
            let element = try W3C_XML.fragment(string)
            return XML(element)
        } catch {
            throw XML.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }
}

// MARK: - Serialize Accessor

extension XML {
    /// Serialization access through the `serialize` accessor.
    public struct Serialize: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(xml: XML) {
            self.xml = xml
        }

        /// Serializes the element to a string.
        ///
        /// - Parameter pretty: Whether to format with indentation.
        /// - Returns: The XML string.
        @inlinable
        public func callAsFunction(pretty: Bool = false) -> String {
            let bytes = xml.raw.encode(options: W3C_XML.Options(prettyPrint: pretty))
            return String(decoding: bytes, as: UTF8.self)
        }

        /// Serializes the element to UTF-8 bytes.
        ///
        /// - Parameter pretty: Whether to format with indentation.
        /// - Returns: The UTF-8 encoded XML bytes.
        @inlinable
        public func bytes(pretty: Bool = false) -> [UInt8] {
            xml.raw.encode(options: W3C_XML.Options(prettyPrint: pretty))
        }
    }

    /// Serialize through the `serialize` accessor.
    @inlinable
    public var serialize: Serialize {
        Serialize(xml: self)
    }
}

// MARK: - Count

extension XML {
    /// The number of child elements.
    @inlinable
    public var count: Int {
        raw.children.count
    }
}

// MARK: - CustomStringConvertible

extension XML: CustomStringConvertible {
    public var description: String {
        serialize()
    }
}
