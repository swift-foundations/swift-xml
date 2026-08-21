extension Double {

    @inlinable
    public init?(_ xml: XML) {
        guard !xml.isNull else { return nil }
        let text = xml.raw.textContent
        guard !text.isEmpty else { return nil }
        self.init(text)
    }
}

extension Float {

    @inlinable
    public init?(_ xml: XML) {
        guard !xml.isNull else { return nil }
        let text = xml.raw.textContent
        guard !text.isEmpty else { return nil }
        self.init(text)
    }
}
