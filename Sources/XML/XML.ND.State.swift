extension XML.ND {
    @usableFromInline
    internal final class State<I: AsyncIteratorProtocol>: @unchecked Sendable
    where I.Element == UInt8 {
        @usableFromInline
        var iterator: I

        @usableFromInline
        var buffer: [UInt8] = []

        @usableFromInline
        var done = false

        @usableFromInline
        init(_ iterator: I) {
            self.iterator = iterator
        }
    }
}

extension XML.ND.State {
    @usableFromInline
    func next() async -> Result<XML.Document, XML.Error>? {
        if done { return nil }

        while true {
            let byte: UInt8?

            do {
                byte = try await iterator.next()
            } catch {
                done = true
                if buffer.isEmpty { return nil }
                defer { buffer.removeAll() }
                return line()
            }

            guard let byte else {

                done = true
                if buffer.isEmpty { return nil }
                defer { buffer.removeAll() }
                return line()
            }

            if byte == 0x0A {
                if buffer.isEmpty { continue }
                defer { buffer.removeAll(keepingCapacity: true) }
                return line()
            }

            if byte == 0x0D { continue }

            buffer.append(byte)
        }
    }

    @usableFromInline
    func line() -> Result<XML.Document, XML.Error> {
        do throws(XML.Error) {
            let doc = try XML.parse(buffer)
            return .success(doc)
        } catch {
            return .failure(error)
        }
    }
}
