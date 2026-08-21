internal import Array_Primitives
internal import Buffer_Linear_Primitive
internal import Buffer_Linear_Primitives
internal import Input_Slice_Primitives
internal import Ownership_Shared_Primitive
import W3C_XML

extension XML {

    public struct Parse: Sendable {
        @usableFromInline
        internal init() {}

        @usableFromInline
        internal let depth: Int = 10000
    }

    public static var parse: Parse { Parse() }
}

extension XML.Parse {

    @inlinable
    public func callAsFunction(_ string: String) throws(XML.Error) -> XML.Document {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(string, maxDepth: depth)
            return XML.Document(doc)
        } catch {
            throw XML.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }

    @inlinable
    public func callAsFunction<Bytes>(_ bytes: Bytes) throws(XML.Error) -> XML.Document
    where Bytes: Swift.Collection<UInt8>, Bytes: Sendable {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(bytes, maxDepth: depth)
            return XML.Document(doc)
        } catch {
            throw XML.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }
}

extension XML.Parse {

    @inlinable
    public func prepared(maxDepth: Int = 10000) -> XML.Prepared {
        XML.Prepared(maxDepth: maxDepth)
    }
}

extension XML.Parse {

    @inlinable
    public func located(maxDepth: Int = 10000) -> XML.Located {
        XML.Located(maxDepth: maxDepth)
    }
}

extension XML.Parse {

    @inlinable
    public func fragment(_ string: String) throws(XML.Error) -> XML {
        try XML.fragment(string)
    }
}
