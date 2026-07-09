import Testing

@testable import XML

extension XML {
@Suite(
    "XML Wrapper Tests",
    .disabled(if: Toolchain.hasTaggedMetadataSIGSEGV, "§A9 Tagged-metadata SIGSEGV on Swift 6.3.x (XML.parse → W3C_XML.parse → Parser.Machine.Parser over Byte.Input forces Tagged VWT); fixed on 6.4+")
)
struct Test {
    @Test
    func `Dynamic member lookup`() throws {
        let doc = try XML.parse(
            """
            <root>
                <user>
                    <name>John</name>
                    <email>john@example.com</email>
                </user>
            </root>
            """
        )

        #expect(String(doc.root.user.name) == "John")
        #expect(String(doc.root.user.email) == "john@example.com")
    }

    @Test
    func `Attributes accessor`() throws {
        let doc = try XML.parse(#"<root id="123" class="test"><item>Hello</item></root>"#)

        #expect(doc.root.element.name == "root")
        #expect(doc.root.attributes["id"] == "123")
        #expect(doc.root.attributes.all["class"] == "test")
        #expect(String(doc.root.item) == "Hello")
        #expect(doc.root.children().count == 1)
    }

    @Test
    func `Children accessor`() throws {
        let doc = try XML.parse(
            """
            <root>
                <item>First</item>
                <item>Second</item>
                <item>Third</item>
                <nested><item>Nested</item></nested>
            </root>
            """
        )

        #expect(doc.root.children.named["item"].count == 3)
        if let first = doc.root.children.first["item"] {
            #expect(String(first) == "First")
        } else {
            Issue.record("Expected to find first item")
        }
        #expect(doc.root.children.descendants["item"].count == 4)
        #expect(doc.root.children.descendant["nested"]?.element.name == "nested")
    }

    @Test
    func `Subscript access`() throws {
        let doc = try XML.parse(
            """
            <root>
                <item>First</item>
                <item>Second</item>
            </root>
            """
        )

        #expect(String(doc.root["item"]) == "First")
        #expect(String(doc.root[0]) == "First")
        #expect(String(doc.root[1]) == "Second")
    }

    @Test
    func `Safe chaining with null elements`() throws {
        let doc = try XML.parse("<root/>")

        #expect(doc.root.nonexistent.isNull)
        #expect(doc.root.nonexistent.child.isNull)
        #expect(doc.root.nonexistent.optional == nil)
        #expect(doc.root[99].isNull)
    }

    @Test
    func `Serialize accessor`() throws {
        let doc = try XML.parse("<root><item>Hello</item></root>")

        let string = doc.root.serialize()
        #expect(string.contains("<root>"))
        #expect(string.contains("<item>"))

        let bytes = doc.root.serialize.bytes()
        #expect(!bytes.isEmpty)
    }

    @Test
    func `Element creation`() {
        let xml = XML.element("item", text: "Hello")
        #expect(xml.element.name == "item")
        #expect(String(xml) == "Hello")
    }

    @Test
    func `Element with children`() {
        let xml = XML.element(
            "root",
            children: [
                XML.element("item", text: "First"),
                XML.element("item", text: "Second"),
            ]
        )

        #expect(xml.children().count == 2)
        #expect(String(xml[0]) == "First")
        #expect(String(xml[1]) == "Second")
    }

    @Test
    func `AllText collects nested text`() throws {
        let doc = try XML.parse("<root>Hello <b>World</b>!</root>")
        #expect(doc.root.text.all == "Hello World!")
    }

    @Test
    func `Count property`() throws {
        let doc = try XML.parse(
            """
            <root>
                <a/><b/><c/>
            </root>
            """
        )
        #expect(doc.root.count == 3)
    }

    @Test
    func `Qualified name access`() throws {
        let doc = try XML.parse(
            """
            <root xmlns:ex="http://example.com">
                <ex:item>Hello</ex:item>
            </root>
            """
        )

        let item = doc.root.children.first["ex:item"]
        #expect(item?.element.prefix == "ex")
        #expect(item?.element.name == "item")
        #expect(item?.element.qualified == "ex:item")
    }
}
}

@Suite
struct `XML.Serializable Tests` {
    @Test
    func `String serialization`() throws {
        let value = "Hello"
        let xml = value.xml
        #expect(String(xml) == "Hello")

        let restored = try String(xml: xml)
        #expect(restored == value)
    }

    @Test
    func `Int serialization`() throws {
        let value = 42
        let xml = value.xml
        #expect(String(xml) == "42")

        let restored = try Int(xml: xml)
        #expect(restored == value)
    }

    @Test
    func `Double serialization`() throws {
        let value = 3.14
        let xml = value.xml
        #expect(String(xml) == "3.14")

        let restored = try Double(xml: xml)
        #expect(restored == value)
    }

    @Test
    func `Bool serialization`() throws {
        let trueXML = true.xml
        let falseXML = false.xml

        #expect(trueXML.element.name == "true")
        #expect(falseXML.element.name == "false")

        #expect(try Bool(xml: trueXML) == true)
        #expect(try Bool(xml: falseXML) == false)
    }

    @Test
    func `Array serialization`() throws {
        let values = [1, 2, 3]
        let xml = values.xml
        #expect(xml.children().count == 3)

        let restored = try [Int](xml: xml)
        #expect(restored == values)
    }

    @Test
    func `Optional serialization`() throws {
        let some: Int? = 42
        let none: Int? = nil

        let someXML = some.xml
        let noneXML = none.xml

        #expect(String(someXML) == "42")
        #expect(noneXML.element.name == "null")

        let restoredSome = try Int?(xml: someXML)
        let restoredNone = try Int?(xml: noneXML)

        #expect(restoredSome == 42)
        #expect(restoredNone == nil)
    }

    @Test
    func `xmlString convenience`() {
        let value = 42
        let string = value.xmlString()
        #expect(string.contains("42"))
    }

    @Test
    func `xmlBytes convenience`() {
        let value = 42
        let bytes = value.xmlBytes()
        #expect(!bytes.isEmpty)
    }
}

extension XML.Test {
@Suite(
    "XML Literal Tests",
    .disabled(
        if: Toolchain.hasTaggedMetadataSIGSEGV,
        "§A9 Tagged-metadata SIGSEGV on Swift 6.3.x (XML string-literal / interpolation init calls Self.fragment → W3C_XML.parse → Parser.Machine.Parser over Byte.Input forces Tagged VWT); fixed on 6.4+"
    )
)
struct Literal {
    @Test
    func `String literal`() {
        let xml: XML = "<item>Hello</item>"
        #expect(xml.element.name == "item")
        #expect(String(xml) == "Hello")
    }

    @Test
    func `String interpolation with escaping`() {
        let name = "John <Doe>"
        let xml: XML = "<name>\(name)</name>"
        #expect(String(xml) == "John <Doe>")
    }

    @Test
    func `Interpolation escapes special characters`() {
        let value = "A & B < C > D"
        let xml: XML = "<data>\(value)</data>"
        #expect(String(xml) == "A & B < C > D")
    }
}
}

extension XML.Document {
@Suite(
    "XML.Document Tests",
    .disabled(if: Toolchain.hasTaggedMetadataSIGSEGV, "§A9 Tagged-metadata SIGSEGV on Swift 6.3.x (XML.parse → W3C_XML.parse → Parser.Machine.Parser over Byte.Input forces Tagged VWT); fixed on 6.4+")
)
struct Test {
    @Test
    func `Document root access`() throws {
        let doc = try XML.parse("<root><child/></root>")
        #expect(doc.root.element.name == "root")
    }

    @Test
    func `Document dynamic member lookup`() throws {
        let doc = try XML.parse("<root><child>Hello</child></root>")
        #expect(String(doc.root.child) == "Hello")
    }
}
}
