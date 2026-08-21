import W3C_XML

extension XML {
    public struct Prepared: Sendable {

        public let maxDepth: Int

        @usableFromInline
        internal init(maxDepth: Int) {
            self.maxDepth = maxDepth
        }
    }
}

extension XML.Prepared {

    @inlinable
    public func parse(_ string: String) throws(XML.Error) -> XML.Document {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(string, maxDepth: maxDepth)
            return XML.Document(doc)
        } catch {
            throw XML.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }

    @inlinable
    public func parse<Bytes>(_ bytes: Bytes) throws(XML.Error) -> XML.Document
    where Bytes: Swift.Collection<UInt8>, Bytes: Sendable {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(bytes, maxDepth: maxDepth)
            return XML.Document(doc)
        } catch {
            throw XML.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }

    @inlinable
    public func fragment(_ string: String) throws(XML.Error) -> XML {
        do {
            let element = try W3C_XML.fragment(string)
            return XML(element)
        } catch {
            throw XML.Error.syntax(message: "\(error)", line: 0, column: 0)
        }
    }
}
