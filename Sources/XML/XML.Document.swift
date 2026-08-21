import W3C_XML

extension XML {

    public struct Document: Sendable, Hashable {

        @usableFromInline
        internal var raw: W3C_XML.Document

        @inlinable
        public init(_ raw: W3C_XML.Document) {
            self.raw = raw
        }

        @inlinable
        public init(root: XML) {
            self.raw = W3C_XML.Document(root: root.raw)
        }

        @inlinable
        public init(
            version: W3C_XML.Declaration.Version = .v1_0,
            encoding: String? = "UTF-8",
            root: XML
        ) {
            self.raw = W3C_XML.Document(
                declaration: W3C_XML.Declaration(
                    version: version,
                    encoding: encoding
                ),
                root: root.raw
            )
        }
    }
}

extension XML.Document {

    @inlinable
    public var root: XML {
        get { XML(raw.root) }
        set { raw.root = newValue.raw }
    }

    @inlinable
    public var version: W3C_XML.Declaration.Version? {
        raw.declaration?.version
    }

    @inlinable
    public var encoding: String? {
        raw.declaration?.encoding
    }

    @inlinable
    public var standalone: Bool? {
        raw.declaration?.standalone
    }
}

extension XML.Document {

    @inlinable
    public var serialize: Serialize {
        Serialize(document: self)
    }
}

extension XML.Document: CustomStringConvertible {
    public var description: String {
        serialize()
    }
}
