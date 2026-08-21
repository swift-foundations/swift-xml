import W3C_XML

extension XML {
    public struct Serialize: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(xml: XML) {
            self.xml = xml
        }
    }
}

extension XML.Serialize {

    @inlinable
    public func callAsFunction(pretty: Bool = false) -> String {
        let bytes = xml.raw.encode(options: W3C_XML.Options(prettyPrint: pretty))
        return String(decoding: bytes, as: UTF8.self)
    }

    @inlinable
    public func bytes(pretty: Bool = false) -> [UInt8] {
        xml.raw.encode(options: W3C_XML.Options(prettyPrint: pretty))
    }
}
