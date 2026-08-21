extension XML {
    public struct LocatedError: Swift.Error, Sendable, Hashable {

        public let error: XML.Error

        public let offset: Int

        @inlinable
        public init(_ error: XML.Error, at offset: Int) {
            self.error = error
            self.offset = offset
        }
    }
}

extension XML.LocatedError: CustomStringConvertible {
    public var description: String {
        "at byte \(offset): \(error)"
    }
}
