/// An error with byte-offset location information.
///
/// This type wraps an `XML.Error` with the byte offset where the error
/// occurred, enabling precise error reporting.
extension XML {
    public struct LocatedError: Swift.Error, Sendable, Hashable {
        /// The underlying XML error.
        public let error: XML.Error

        /// Byte offset from the start of input where the error occurred.
        public let offset: Int

        /// Creates a located error.
        ///
        /// - Parameters:
        ///   - error: The underlying error.
        ///   - offset: Byte offset from input start.
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
