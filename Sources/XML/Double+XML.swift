// Extensions for converting XML elements to Double.

// MARK: - Double from XML

extension Double {
    /// Creates a double from an XML element's text content.
    ///
    /// Returns `nil` if the element is null, has no text content,
    /// or the text cannot be parsed as a double.
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

// MARK: - Float from XML

extension Float {
    /// Creates a float from an XML element's text content.
    ///
    /// Returns `nil` if the element is null, has no text content,
    /// or the text cannot be parsed as a float.
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
