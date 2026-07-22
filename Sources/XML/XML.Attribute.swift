extension XML {
    /// An ordered XML attribute supplied when constructing an element.
    public struct Attribute: Sendable, Hashable {
        public var name: Swift.String
        public var value: Swift.String

        public init(name: Swift.String, value: Swift.String) {
            self.name = name
            self.value = value
        }
    }
}
