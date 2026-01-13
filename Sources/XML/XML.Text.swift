import W3C_XML

/// Nested accessor for XML text content access.
///
/// Provides access to text content with variants for recursive extraction.
///
/// ## Usage
///
/// ```swift
/// xml.user.name.text()      // String - direct text content
/// xml.user.name.text.all    // String - all text including descendants
/// ```
extension XML {
    public struct Text: Sendable {
        @usableFromInline
        let xml: XML

        @usableFromInline
        init(_ xml: XML) {
            self.xml = xml
        }
    }
}

// MARK: - Primary Access (callAsFunction)

extension XML.Text {
    /// Direct text content of this element.
    ///
    /// - Returns: The text content, or empty string if none.
    @inlinable
    public func callAsFunction() -> String {
        xml.raw.textContent
    }
}

// MARK: - All Text (Recursive)

extension XML.Text {
    /// All text content including nested elements.
    ///
    /// Recursively collects text from this element and all descendants.
    @inlinable
    public var all: String {
        collectAllText(xml.raw)
    }

    /// Collects all text from an element and its descendants.
    @usableFromInline
    internal func collectAllText(_ element: W3C_XML.Element) -> String {
        var result = ""
        for content in element.content {
            switch content {
            case .text(let t):
                result += t
            case .cdata(let c):
                result += c
            case .element(let e):
                result += collectAllText(e)
            default:
                break
            }
        }
        return result
    }
}

// MARK: - Instance Accessor

extension XML {
    /// Access text content.
    ///
    /// ```swift
    /// xml.user.name.text()      // String - direct text
    /// xml.user.name.text.all    // String - all text including descendants
    /// ```
    @inlinable
    public var text: Text {
        Text(self)
    }
}
