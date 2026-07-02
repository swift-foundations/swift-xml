# swift-xml

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Ergonomic XML for Swift: dynamic-member navigation, typed-throws parsing, and async streaming over the W3C XML document model.

---

## Key Features

- **Dynamic-member navigation** — `order.customer.name` walks the element tree; missing elements return a chainable null placeholder instead of crashing
- **Typed throws end-to-end** — every parsing and deserialization API throws `XML.Error` (or `XML.LocatedError`); no `any Error` escapes the surface
- **Concurrency-ready parsing** — `XML.parse.prepared()` returns a `Sendable` parser that is safe to share across tasks, with stack-safe parsing to 10,000 nesting levels
- **`XML.Serializable`** — round-trip Swift values to and from XML; `String`, `Int`, `Double`, `Bool`, `Optional`, and `Array` conform out of the box
- **Async streaming** — parse from any `AsyncSequence` of bytes, including newline-delimited XML streams that survive per-line errors
- **XML string literals** — `let item: XML = "<item>Hello</item>"`, with escaping string interpolation
- **Value semantics** — `XML` is a `Sendable`, `Hashable` struct

---

## Quick Start

```swift
import XML

let doc = try XML.parse("""
    <order id="7042">
        <customer>Alicia</customer>
        <total>129.95</total>
        <items>
            <item>keyboard</item>
            <item>trackpad</item>
        </items>
    </order>
    """)

let order = doc.root

String(order.customer)              // "Alicia"
Double(order.total)                 // Optional(129.95)
order.attributes["id"]              // Optional("7042")
order.items.children.named["item"]  // [XML] — both <item> elements

// Missing elements chain safely — no crash, no force-unwrap:
order.shipping.address.optional     // nil
```

Navigation by dot syntax (`order.customer`) and by subscript (`order["customer"]`) are equivalent; a lookup that finds nothing returns a null element whose `optional` property is `nil`, so deep paths never trap.

---

## Installation

Add swift-xml to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-foundations/swift-xml.git", branch: "main")
]
```

Add the product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "XML", package: "swift-xml")
    ]
)
```

### Requirements

- Swift 6.3+ toolchain
- macOS 26+, iOS 26+, tvOS 26+, watchOS 26+, visionOS 26+

---

## Usage

### Parsing

```swift
import XML

// Direct parse — String or any Collection<UInt8>
let doc = try XML.parse("<config><debug>true</debug></config>")

// Fragment parse — a single element, no document wrapper
let item = try XML.fragment("<item>Hello</item>")

// Prepared parser — Sendable, safe to share across concurrent tasks
let parser = XML.parse.prepared()
let parsed = try parser.parse(bytes)

// Located errors — byte-offset error tracking for diagnostics
do {
    let doc = try XML.parse.located().parse(bytes)
} catch {
    print("at byte \(error.offset): \(error.error)")
}
```

### Serialization

```swift
let xml = XML.element("greeting", text: "Hello")

xml.serialize()                  // "<greeting>Hello</greeting>"
xml.serialize(pretty: true)      // Indented output
xml.serialize.bytes()            // [UInt8]

let doc = XML.Document(root: xml)
doc.serialize()                  // Full document with XML declaration
```

### `XML.Serializable`

Conform a type once and gain string, byte, and async initializers plus serialization methods:

```swift
struct Person: XML.Serializable {
    var name: String
    var age: Int

    static func serialize(_ value: Person) -> XML {
        XML.element("person", children: [
            XML.element("name", text: value.name),
            XML.element("age", text: String(value.age))
        ])
    }

    static func deserialize(_ xml: XML) throws(XML.Error) -> Person {
        guard let nameXML = xml.children.first["name"],
              let name = String?(nameXML) else {
            throw .elementNotFound(name: "name")
        }
        guard let ageXML = xml.children.first["age"],
              let age = Int(ageXML) else {
            throw .elementNotFound(name: "age")
        }
        return Person(name: name, age: age)
    }
}

let person = try Person(xmlString: "<person><name>Ada</name><age>36</age></person>")
person.xmlString(pretty: true)   // Round-trip back to XML
```

### Async Streaming

```swift
// Buffer an async byte sequence, then parse
let doc = try await XML.parse(collecting: url.resourceBytes)

// Newline-delimited XML: one document per line, errors don't stop the stream
for await result in XML.ND.stream(bytes) {
    switch result {
    case .success(let doc):
        process(doc)
    case .failure(let error):
        log(error)   // Stream continues with the next line
    }
}
```

### Advanced Access

The `W3C_XML` module is re-exported, so the underlying document model (`W3C_XML.Element`, `W3C_XML.Document`, entity escaping, encode options) is available without an extra import.

```swift
xml.element.name         // Element name (local part)
xml.element.qualified    // "prefix:name"
xml.text()               // Direct text content
xml.text.all             // Text including all descendants
xml.children()           // [XML] — all children
xml.children.descendants["item"]   // Recursive search
xml.attributes.all       // [String: String]
```

---

## Error Handling

All throwing APIs use typed throws. Parsing and deserialization throw `XML.Error`; the located parser throws `XML.LocatedError`.

```
XML.Error
├── .syntax(message:line:column:)    // Malformed XML
├── .encoding(String)                // Encoding failure
├── .depth(limit:)                   // Nesting depth limit exceeded
├── .empty                           // Empty input
├── .elementNotFound(name:)          // Deserialization: required element missing
├── .attributeNotFound(name:)        // Deserialization: required attribute missing
└── .typeMismatch(expected:got:)     // Deserialization: content has the wrong type

XML.LocatedError                     // Thrown by XML.parse.located()
├── error: XML.Error                 // The underlying error
└── offset: Int                      // Byte offset in the input
```

```swift
do {
    let person = try Person(xmlString: payload)
} catch .syntax(let message, let line, let column) {
    report("malformed XML at \(line):\(column): \(message)")
} catch .elementNotFound(let name) {
    report("missing <\(name)>")
} catch .typeMismatch(let expected, let got) {
    report("expected \(expected), got \(got)")
} catch {
    // .encoding, .depth, .empty, .attributeNotFound
    report("\(error)")
}
```

---

## Related Packages

### Dependencies

- swift-w3c-xml (private, pre-release) — W3C XML document model, parser, and serializer; re-exported as `W3C_XML`.
- swift-async (public, pre-release) — `Async.Stream` used by the newline-delimited streaming API.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public flip.*
<!-- END: discussion -->

---

## License

Apache 2.0. See [LICENSE](LICENSE.md).
