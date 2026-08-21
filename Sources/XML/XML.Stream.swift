public import Async
import W3C_XML

extension XML {

    @inlinable
    public static func parse<S: AsyncSequence & Sendable>(
        collecting bytes: S
    ) async throws(Self.Error) -> XML.Document
    where S.Element == UInt8 {
        var buffer: [UInt8] = []
        do {
            for try await byte in bytes {
                buffer.append(byte)
            }
        } catch {
            throw .syntax(message: "Error reading bytes: \(error)", line: 0, column: 0)
        }
        return try parse(buffer)
    }
}

extension XML.Parse {

    @inlinable
    public func collecting<S: AsyncSequence & Sendable>(
        _ bytes: S
    ) async throws(XML.Error) -> XML.Document
    where S.Element == UInt8 {
        try await XML.parse(collecting: bytes)
    }
}

extension XML.Serializable {

    @inlinable
    public init<S: AsyncSequence & Sendable>(
        collecting bytes: S
    ) async throws(XML.Error)
    where S.Element == UInt8 {
        let doc = try await XML.parse(collecting: bytes)
        self = try Self.deserialize(doc.root)
    }
}

extension XML {

    public enum ND: Sendable {}
}

extension XML.ND {

    @inlinable
    public static func stream<S: AsyncSequence & Sendable>(
        _ bytes: S
    ) -> Async.Stream<Result<XML.Document, XML.Error>>
    where S.Element == UInt8 {
        Async.Stream {
            let state = State(bytes.makeAsyncIterator())
            return Async.Stream<Result<XML.Document, XML.Error>>.Iterator {
                await state.next()
            }
        }
    }
}

extension XML.Parse {

    @inlinable
    public func stream<S: AsyncSequence & Sendable>(
        nd bytes: S
    ) -> Async.Stream<Result<XML.Document, XML.Error>>
    where S.Element == UInt8 {
        XML.ND.stream(bytes)
    }
}
