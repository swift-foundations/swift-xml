// Extensions for converting XML elements to String.
//
// Following the pattern of preferring extension initializers for
// type transformations rather than computed properties.
//
// ## Usage
//
// ```swift
// let doc = try XML.parse("<user><name>John</name></user>")
// let name = String(doc.root.user.name)  // "John"
// ```

// MARK: - String from XML

extension String {
    /// Creates a string from an XML element's text content.
    ///
    /// Returns the direct text content of the element. For null elements,
    /// returns an empty string.
    ///
    /// - Parameter xml: The XML element.
    @inlinable
    public init(_ xml: XML) {
        self = xml.raw.textContent
    }
}

extension String {
    /// Creates a string from an XML element's text content, if available.
    ///
    /// Returns `nil` if the element is null or has no text content.
    ///
    /// - Parameter xml: The XML element.
    @inlinable
    public init?(_ xml: XML?) {
        guard let xml, !xml.isNull else { return nil }
        let text = xml.raw.textContent
        guard !text.isEmpty else { return nil }
        self = text
    }
}
