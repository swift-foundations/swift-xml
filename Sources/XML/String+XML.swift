extension String {

    @inlinable
    public init(_ xml: XML) {
        self = xml.raw.textContent
    }
}

extension String {

    @inlinable
    public init?(_ xml: XML?) {
        guard let xml, !xml.isNull else { return nil }
        let text = xml.raw.textContent
        guard !text.isEmpty else { return nil }
        self = text
    }
}
