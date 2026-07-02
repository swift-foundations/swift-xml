/// StreamTests.swift
/// swift-xml

import Testing
@testable import XML

@Suite("Stream Tests")
struct StreamTests {

    // MARK: - ND XML Streaming

    @Test
    func `Parse ND XML stream`() async throws {
        let input = """
        <?xml version="1.0"?><item><id>1</id></item>
        <?xml version="1.0"?><item><id>2</id></item>
        <?xml version="1.0"?><item><id>3</id></item>
        """

        let bytes = AsyncStream<UInt8> { continuation in
            for byte in input.utf8 {
                continuation.yield(byte)
            }
            continuation.finish()
        }

        var ids: [String] = []
        for result in try await collect(XML.ND.stream(bytes)) {
            let doc = try result.get()
            let id = doc.root["id"].text()
            ids.append(id)
        }

        #expect(ids == ["1", "2", "3"])
    }

    @Test
    func `Skip empty lines in ND XML`() async throws {
        let input = """
        <?xml version="1.0"?><item><id>1</id></item>

        <?xml version="1.0"?><item><id>2</id></item>

        """

        let bytes = AsyncStream<UInt8> { continuation in
            for byte in input.utf8 {
                continuation.yield(byte)
            }
            continuation.finish()
        }

        var ids: [String] = []
        for result in try await collect(XML.ND.stream(bytes)) {
            let doc = try result.get()
            let id = doc.root["id"].text()
            ids.append(id)
        }

        #expect(ids == ["1", "2"])
    }

    @Test
    func `Continue after malformed line`() async throws {
        let input = """
        <?xml version="1.0"?><item><id>1</id></item>
        not valid xml
        <?xml version="1.0"?><item><id>3</id></item>
        """

        let bytes = AsyncStream<UInt8> { continuation in
            for byte in input.utf8 {
                continuation.yield(byte)
            }
            continuation.finish()
        }

        var successes: [String] = []
        var failures = 0

        for result in try await collect(XML.ND.stream(bytes)) {
            switch result {
            case .success(let doc):
                let id = doc.root["id"].text()
                successes.append(id)
            case .failure:
                failures += 1
            }
        }

        #expect(successes == ["1", "3"])
        #expect(failures == 1)
    }

    @Test
    func `Handle CRLF line endings`() async throws {
        let input = "<?xml version=\"1.0\"?><item><id>1</id></item>\r\n<?xml version=\"1.0\"?><item><id>2</id></item>\r\n"

        let bytes = AsyncStream<UInt8> { continuation in
            for byte in input.utf8 {
                continuation.yield(byte)
            }
            continuation.finish()
        }

        var ids: [String] = []
        for result in try await collect(XML.ND.stream(bytes)) {
            let doc = try result.get()
            let id = doc.root["id"].text()
            ids.append(id)
        }

        #expect(ids == ["1", "2"])
    }

    @Test
    func `Parse without trailing newline`() async throws {
        let input = "<?xml version=\"1.0\"?><item><id>1</id></item>\n<?xml version=\"1.0\"?><item><id>2</id></item>"

        let bytes = AsyncStream<UInt8> { continuation in
            for byte in input.utf8 {
                continuation.yield(byte)
            }
            continuation.finish()
        }

        var ids: [String] = []
        for result in try await collect(XML.ND.stream(bytes)) {
            let doc = try result.get()
            let id = doc.root["id"].text()
            ids.append(id)
        }

        #expect(ids == ["1", "2"])
    }

    // MARK: - Single Document Async Parse

    @Test
    func `Parse single document from async bytes`() async throws {
        let input = """
        <?xml version="1.0" encoding="UTF-8"?>
        <person>
            <name>John</name>
            <age>30</age>
        </person>
        """

        let bytes = AsyncStream<UInt8> { continuation in
            for byte in input.utf8 {
                continuation.yield(byte)
            }
            continuation.finish()
        }

        let doc = try await XML.parse(collecting: bytes)

        #expect(doc.root["name"].text() == "John")
        #expect(doc.root["age"].text() == "30")
    }

    @Test
    func `Parse via accessor`() async throws {
        let input = """
        <?xml version="1.0"?><greeting>Hello</greeting>
        """

        let bytes = AsyncStream<UInt8> { continuation in
            for byte in input.utf8 {
                continuation.yield(byte)
            }
            continuation.finish()
        }

        let doc = try await XML.parse.collecting(bytes)

        #expect(doc.root.text() == "Hello")
    }

    @Test
    func `Stream via accessor`() async throws {
        let input = """
        <?xml version="1.0"?><item><id>1</id></item>
        <?xml version="1.0"?><item><id>2</id></item>
        """

        let bytes = AsyncStream<UInt8> { continuation in
            for byte in input.utf8 {
                continuation.yield(byte)
            }
            continuation.finish()
        }

        var count = 0
        for result in try await collect(XML.parse.stream(nd: bytes)) {
            _ = try result.get()
            count += 1
        }

        #expect(count == 2)
    }

    @Test
    func `Parse empty async stream`() async {
        let bytes = AsyncStream<UInt8> { continuation in
            continuation.finish()
        }

        do {
            _ = try await XML.parse(collecting: bytes)
            Issue.record("Expected error for empty input")
        } catch {
            // Expected
        }
    }

    // MARK: - XML.Serializable Async

    @Test
    func `Deserialize from async bytes`() async throws {
        let input = """
        <?xml version="1.0"?><value>42</value>
        """

        let bytes = AsyncStream<UInt8> { continuation in
            for byte in input.utf8 {
                continuation.yield(byte)
            }
            continuation.finish()
        }

        // Parse then deserialize to avoid Plist/XML ambiguity
        let doc = try await XML.parse(collecting: bytes)
        let value = try Int.deserialize(doc.root)

        #expect(value == 42)
    }
}

/// Iterates through `AsyncSequence` protocol dispatch: the concrete
/// iterator member lives in swift-async's internal-only Async Stream Core
/// module, so direct `for await` over the concrete stream type fails
/// MemberImportVisibility.
private func collect<S: AsyncSequence>(_ sequence: S) async throws -> [S.Element] {
    var elements: [S.Element] = []
    for try await element in sequence { elements.append(element) }
    return elements
}
