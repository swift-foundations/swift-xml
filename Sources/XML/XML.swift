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
/// // Text extraction via String initializer
/// String(xml.user.name)              // "John"
/// Int(xml.user.age)                  // Optional(30)
///
/// // Dynamic member lookup for navigation
/// xml.user.name                      // XML element
/// xml["user"]["name"]                // Same via subscript
///
/// // Attributes
/// xml.user.attributes["id"]          // Optional("123")
/// xml.user.attributes.all            // ["id": "123", ...]
///
/// // Children
/// xml.items.children()               // [XML] - all children
/// xml.items.children.named["item"]   // [XML] - filtered
/// xml.items.children.first["item"]   // XML? - first match
/// ```
///
/// ## Serialization
///
/// ```swift
/// let string = xml.serialize()
/// let pretty = xml.serialize(pretty: true)
/// ```

public import Array_Primitives
public import Buffer_Linear_Primitive
public import Buffer_Linear_Primitives
public import Input_Slice_Primitives
public import Ownership_Shared_Primitive
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
        XML(
            W3C_XML.Element(
                name: name,
                content: [.text(text)]
            )
        )
    }

    /// Creates an XML element with children.
    @inlinable
    public static func element(_ name: String, children: [XML]) -> XML {
        XML(
            W3C_XML.Element(
                name: name,
                content: children.map { .element($0.raw) }
            )
        )
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

// MARK: - Subscripts

extension XML {
    /// Accesses the first child element with the given name.
    ///
    /// Returns an empty XML element if not found (allows safe chaining).
    @inlinable
    public subscript(name: String) -> XML {
        raw.child(name).map(Self.init) ?? XML(W3C_XML.Element(name: "_null"))
    }

    /// Accesses a child element by index.
    ///
    /// Returns an empty XML element if out of bounds.
    @inlinable
    public subscript(index: Int) -> XML {
        let allChildren = raw.children
        guard index >= 0 && index < allChildren.count else {
            return XML(W3C_XML.Element(name: "_null"))
        }
        return XML(allChildren[index])
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
    public static func parse(_ string: String) throws(Self.Error) -> XML.Document {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(string)
            return Self.Document(doc)
        } catch {
            throw Self.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }

    /// Parses an XML document from UTF-8 bytes.
    ///
    /// - Parameter bytes: The UTF-8 encoded XML bytes.
    /// - Returns: The parsed document.
    /// - Throws: `XML.Error` if parsing fails.
    @inlinable
    public static func parse<Bytes>(_ bytes: Bytes) throws(Self.Error) -> XML.Document
    where Bytes: Swift.Collection<UInt8>, Bytes: Sendable {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(bytes)
            return Self.Document(doc)
        } catch {
            throw Self.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }

    /// Parses an XML fragment (single element).
    ///
    /// - Parameter string: The XML fragment string to parse.
    /// - Returns: The parsed element.
    /// - Throws: `XML.Error` if parsing fails.
    @inlinable
    public static func fragment(_ string: String) throws(Self.Error) -> XML {
        do {
            let element = try W3C_XML.fragment(string)
            return XML(element)
        } catch {
            throw Self.Error.syntax(message: "\(error)", line: 0, column: 0)
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
    }

    /// Serialize through the `serialize` accessor.
    @inlinable
    public var serialize: Serialize {
        Serialize(xml: self)
    }
}

extension XML.Serialize {
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
