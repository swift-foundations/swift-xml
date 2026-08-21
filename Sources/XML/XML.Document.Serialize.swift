import W3C_XML

extension XML.Document {
    public struct Serialize: Sendable {
        @usableFromInline
        let document: XML.Document

        @usableFromInline
        init(document: XML.Document) {
            self.document = document
        }
    }
}

extension XML.Document.Serialize {

    @inlinable
    public func callAsFunction(pretty: Bool = false) -> String {
        let bytes = document.raw.encode(options: W3C_XML.Options(prettyPrint: pretty))
        return String(decoding: bytes, as: UTF8.self)
    }

    @inlinable
    public func bytes(pretty: Bool = false) -> [UInt8] {
        document.raw.encode(options: W3C_XML.Options(prettyPrint: pretty))
    }
}
