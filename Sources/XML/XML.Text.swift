import W3C_XML

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

extension XML.Text {

    @inlinable
    public func callAsFunction() -> String {
        xml.raw.textContent
    }
}

extension XML.Text {

    @inlinable
    public var all: String {
        collect(xml.raw)
    }

    @usableFromInline
    internal func collect(_ element: W3C_XML.Element) -> String {
        var result = ""
        for content in element.content {
            switch content {
            case .text(let t):
                result += t

            case .cdata(let c):
                result += c

            case .element(let e):
                result += collect(e)

            default:
                break
            }
        }
        return result
    }
}

extension XML {

    @inlinable
    public var text: Text {
        Text(self)
    }
}
