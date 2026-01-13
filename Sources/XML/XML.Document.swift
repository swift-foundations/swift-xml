/// XML.Document.swift
/// swift-xml
///
/// XML Document wrapper type

import W3C_XML

extension XML {
    /// An XML document.
    ///
    /// Wraps `W3C_XML.Document` with ergonomic APIs.
    public struct Document: Sendable, Hashable {
        /// The underlying W3C_XML document.
        @usableFromInline
        internal var raw: W3C_XML.Document

        /// Creates a Document from a W3C_XML.Document.
        @inlinable
        public init(_ raw: W3C_XML.Document) {
            self.raw = raw
        }

        /// Creates a document with a root element.
        @inlinable
        public init(root: XML) {
            self.raw = W3C_XML.Document(root: root.raw)
        }

        /// Creates a document with declaration and root element.
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

// MARK: - Document Properties

extension XML.Document {
    /// The root element.
    @inlinable
    public var root: XML {
        get { XML(raw.root) }
        set { raw.root = newValue.raw }
    }

    /// The XML version.
    @inlinable
    public var version: W3C_XML.Declaration.Version? {
        raw.declaration?.version
    }

    /// The document encoding.
    @inlinable
    public var encoding: String? {
        raw.declaration?.encoding
    }

    /// Whether the document is standalone.
    @inlinable
    public var standalone: Bool? {
        raw.declaration?.standalone
    }
}

// MARK: - Document Serialize

extension XML.Document {
    /// Serialization access through the `serialize` accessor.
    public struct Serialize: Sendable {
        @usableFromInline
        let document: XML.Document

        @usableFromInline
        init(document: XML.Document) {
            self.document = document
        }

        /// Serializes the document to a string.
        ///
        /// - Parameter pretty: Whether to format with indentation.
        /// - Returns: The XML string.
        @inlinable
        public func callAsFunction(pretty: Bool = false) -> String {
            let bytes = document.raw.encode(options: W3C_XML.Options(prettyPrint: pretty))
            return String(decoding: bytes, as: UTF8.self)
        }

        /// Serializes the document to UTF-8 bytes.
        ///
        /// - Parameter pretty: Whether to format with indentation.
        /// - Returns: The UTF-8 encoded XML bytes.
        @inlinable
        public func bytes(pretty: Bool = false) -> [UInt8] {
            document.raw.encode(options: W3C_XML.Options(prettyPrint: pretty))
        }
    }

    /// Serialize through the `serialize` accessor.
    @inlinable
    public var serialize: Serialize {
        Serialize(document: self)
    }
}

// MARK: - Document CustomStringConvertible

extension XML.Document: CustomStringConvertible {
    public var description: String {
        serialize()
    }
}
