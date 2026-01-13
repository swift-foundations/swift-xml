/// Extensions for converting XML elements to Bool.

// MARK: - Bool from XML

extension Bool {
    /// Creates a boolean from an XML element's text content.
    ///
    /// Recognizes the following values (case-insensitive):
    /// - `true`: "true", "yes", "1"
    /// - `false`: "false", "no", "0"
    ///
    /// Returns `nil` if the element is null, has no text content,
    /// or the text is not a recognized boolean value.
    ///
    /// - Parameter xml: The XML element.
    @inlinable
    public init?(_ xml: XML) {
        guard !xml.isNull else { return nil }
        let text = xml.raw.textContent.lowercased()
        switch text {
        case "true", "yes", "1":
            self = true
        case "false", "no", "0":
            self = false
        default:
            return nil
        }
    }
}
