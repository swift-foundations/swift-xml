import W3C_XML

extension XML {
    public struct Located: Sendable {

        public let maxDepth: Int

        @usableFromInline
        internal init(maxDepth: Int) {
            self.maxDepth = maxDepth
        }
    }
}

extension XML.Located {

    @inlinable
    public func parse(_ string: String) throws(XML.LocatedError) -> XML.Document {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(string, maxDepth: maxDepth)
            return XML.Document(doc)
        } catch let error {
            throw XML.LocatedError(
                XML.Error.syntax(message: "\(error)", line: 0, column: 0),
                at: error.offset
            )
        }
    }

    @inlinable
    public func parse<Bytes>(_ bytes: Bytes) throws(XML.LocatedError) -> XML.Document
    where Bytes: Swift.Collection<UInt8>, Bytes: Sendable {
        do throws(W3C_XML.Parse.Error) {
            let doc = try W3C_XML.parse(bytes, maxDepth: maxDepth)
            return XML.Document(doc)
        } catch let error {
            throw XML.LocatedError(
                XML.Error.syntax(message: "\(error)", line: 0, column: 0),
                at: error.offset
            )
        }
    }
}

extension W3C_XML.Parse.Error {

    @usableFromInline
    var offset: Int {

        return 0
    }
}
