// Extensions for converting XML elements to Int.

// MARK: - Int from XML

extension Int {
    /// Creates an integer from an XML element's text content.
    ///
    /// Returns `nil` if the element is null, has no text content,
    /// or the text cannot be parsed as an integer.
    ///
    /// - Parameter xml: The XML element.
    @inlinable
    public init?(_ xml: XML) {
        guard !xml.isNull else { return nil }
        let text = xml.raw.textContent
        guard !text.isEmpty else { return nil }
        self.init(text)
    }
}

// MARK: - Int64 from XML

extension Int64 {
    /// Creates a 64-bit integer from an XML element's text content.
    ///
    /// Returns `nil` if the element is null, has no text content,
    /// or the text cannot be parsed as an integer.
    ///
    /// - Parameter xml: The XML element.
    @inlinable
    public init?(_ xml: XML) {
        guard !xml.isNull else { return nil }
        let text = xml.raw.textContent
        guard !text.isEmpty else { return nil }
        self.init(text)
    }
}
