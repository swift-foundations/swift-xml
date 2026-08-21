internal import Array_Primitives
internal import Buffer_Linear_Primitive
internal import Buffer_Linear_Primitives
internal import Input_Slice_Primitives
internal import Ownership_Shared_Primitive
import W3C_XML

@dynamicMemberLookup
public struct XML: Sendable, Hashable {

    @usableFromInline
    internal var raw: W3C_XML.Element

    @inlinable
    public init(_ raw: W3C_XML.Element) {
        self.raw = raw
    }
}

extension XML {

    @inlinable
    public static func element(_ name: String) -> XML {
        XML(W3C_XML.Element(name: name))
    }

    @inlinable
    public static func element(_ name: String, text: String) -> XML {
        XML(
            W3C_XML.Element(
                name: name,
                content: [.text(text)]
            )
        )
    }

    @inlinable
    public static func element(_ name: String, children: [XML]) -> XML {
        XML(
            W3C_XML.Element(
                name: name,
                content: children.map { .element($0.raw) }
            )
        )
    }

    @inlinable
    public static func element(
        _ name: Swift.String,
        attributes: [Attribute],
        children: [XML] = []
    ) -> XML {
        XML(
            W3C_XML.Element(
                name: name,
                attributes: attributes.map {
                    W3C_XML.Attribute(name: $0.name, value: $0.value)
                },
                content: children.map { .element($0.raw) }
            )
        )
    }
}

extension XML {

    @inlinable
    public var isText: Bool {
        !raw.textContent.isEmpty
    }

    @inlinable
    public var isEmpty: Bool {
        raw.content.isEmpty
    }

    @inlinable
    public var isParent: Bool {
        raw.children.count > 0
    }
}

extension XML {

    @inlinable
    public subscript(name: String) -> XML {
        raw.child(name).map(Self.init) ?? XML(W3C_XML.Element(name: "_null"))
    }

    @inlinable
    public subscript(index: Int) -> XML {
        let allChildren = raw.children
        guard index >= 0 && index < allChildren.count else {
            return XML(W3C_XML.Element(name: "_null"))
        }
        return XML(allChildren[index])
    }
}

extension XML {

    @inlinable
    public subscript(dynamicMember member: String) -> XML {
        self[member]
    }
}

extension XML {

    @inlinable
    public var isNull: Bool {
        raw.name.local == "_null"
    }

    @inlinable
    public var optional: XML? {
        isNull ? nil : self
    }
}

extension XML {

    @inlinable
    public static func parse(_ string: String) throws(Self.Error) -> XML.Document {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(string)
            return Self.Document(doc)
        } catch {
            throw Self.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }

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

extension XML {

    @inlinable
    public var serialize: Serialize {
        Serialize(xml: self)
    }
}

extension XML {

    @inlinable
    public var count: Int {
        raw.children.count
    }
}

extension XML: CustomStringConvertible {
    public var description: String {
        serialize()
    }
}
