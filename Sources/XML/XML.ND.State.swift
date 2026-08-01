// WHY: Category D — structural Sendable workaround.
// WHY: AsyncIteratorProtocol generic parameter blocks Sendable inference.
// WHY: No caller invariant to uphold — data is structurally safe.
// WHEN TO REMOVE: When compiler gains structural Sendable inference through
// WHEN TO REMOVE: AsyncIteratorProtocol generic parameters.
// TRACKING: unsafe-audit-findings.md Category D; SP-4.
/// Internal state machine for ND XML parsing.
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
            // swift-linter:disable:next do throws for typed catch
            // REASON: AsyncIteratorProtocol.next() throws untyped (protocol requirement); no E to name.
            do {
                byte = try await iterator.next()
            } catch {
                done = true
                if buffer.isEmpty { return nil }
                defer { buffer.removeAll() }
                return line()
            }

            guard let byte else {
                // End of input
                done = true
                if buffer.isEmpty { return nil }
                defer { buffer.removeAll() }
                return line()
            }

            if byte == 0x0A {  // LF - newline
                if buffer.isEmpty { continue }  // Skip empty lines
                defer { buffer.removeAll(keepingCapacity: true) }
                return line()
            }

            if byte == 0x0D { continue }  // Skip CR

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
