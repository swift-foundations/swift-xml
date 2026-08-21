extension Bool {

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
