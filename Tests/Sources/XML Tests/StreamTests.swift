/// StreamTests.swift
/// swift-xml

import Testing
@testable import XML

@Suite("Stream Tests")
struct StreamTests {

    // MARK: - ND XML Streaming

    @Test("Parse ND XML stream")
    func parseNDXML() async throws {
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
        for await result in XML.ND.stream(bytes) {
            let doc = try result.get()
            let id = doc.root["id"].text()
            ids.append(id)
        }

        #expect(ids == ["1", "2", "3"])
    }

    @Test("Skip empty lines in ND XML")
    func skipEmptyLines() async throws {
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
        for await result in XML.ND.stream(bytes) {
            let doc = try result.get()
            let id = doc.root["id"].text()
            ids.append(id)
        }

        #expect(ids == ["1", "2"])
    }

    @Test("Continue after malformed line")
    func continueAfterError() async {
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

        for await result in XML.ND.stream(bytes) {
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

    @Test("Handle CRLF line endings")
    func handleCRLF() async throws {
        let input = "<?xml version=\"1.0\"?><item><id>1</id></item>\r\n<?xml version=\"1.0\"?><item><id>2</id></item>\r\n"

        let bytes = AsyncStream<UInt8> { continuation in
            for byte in input.utf8 {
                continuation.yield(byte)
            }
            continuation.finish()
        }

        var ids: [String] = []
        for await result in XML.ND.stream(bytes) {
            let doc = try result.get()
            let id = doc.root["id"].text()
            ids.append(id)
        }

        #expect(ids == ["1", "2"])
    }

    @Test("Parse without trailing newline")
    func noTrailingNewline() async throws {
        let input = "<?xml version=\"1.0\"?><item><id>1</id></item>\n<?xml version=\"1.0\"?><item><id>2</id></item>"

        let bytes = AsyncStream<UInt8> { continuation in
            for byte in input.utf8 {
                continuation.yield(byte)
            }
            continuation.finish()
        }

        var ids: [String] = []
        for await result in XML.ND.stream(bytes) {
            let doc = try result.get()
            let id = doc.root["id"].text()
            ids.append(id)
        }

        #expect(ids == ["1", "2"])
    }

    // MARK: - Single Document Async Parse

    @Test("Parse single document from async bytes")
    func parseSingleAsync() async throws {
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

    @Test("Parse via accessor")
    func parseViaAccessor() async throws {
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

    @Test("Stream via accessor")
    func streamViaAccessor() async throws {
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
        for await result in XML.parse.stream(nd: bytes) {
            _ = try result.get()
            count += 1
        }

        #expect(count == 2)
    }

    @Test("Parse empty async stream")
    func parseEmptyAsync() async {
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

    @Test("Deserialize from async bytes")
    func deserializeAsync() async throws {
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
