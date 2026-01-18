import Testing
@testable import XML

@Suite("XML Wrapper Tests")
struct XMLWrapperTests {
    @Test("Dynamic member lookup")
    func dynamicMemberLookup() throws {
        let doc = try XML.parse("""
            <root>
                <user>
                    <name>John</name>
                    <email>john@example.com</email>
                </user>
            </root>
            """)

        #expect(String(doc.root.user.name) == "John")
        #expect(String(doc.root.user.email) == "john@example.com")
    }

    @Test("Attributes accessor")
    func attributesAccessor() throws {
        let doc = try XML.parse(#"<root id="123" class="test"><item>Hello</item></root>"#)

        #expect(doc.root.element.name == "root")
        #expect(doc.root.attributes["id"] == "123")
        #expect(doc.root.attributes.all["class"] == "test")
        #expect(String(doc.root.item) == "Hello")
        #expect(doc.root.children().count == 1)
    }

    @Test("Children accessor")
    func childrenAccessor() throws {
        let doc = try XML.parse("""
            <root>
                <item>First</item>
                <item>Second</item>
                <item>Third</item>
                <nested><item>Nested</item></nested>
            </root>
            """)

        #expect(doc.root.children.named["item"].count == 3)
        if let first = doc.root.children.first["item"] {
            #expect(String(first) == "First")
        } else {
            Issue.record("Expected to find first item")
        }
        #expect(doc.root.children.descendants["item"].count == 4)
        #expect(doc.root.children.descendant["nested"]?.element.name == "nested")
    }

    @Test("Subscript access")
    func subscriptAccess() throws {
        let doc = try XML.parse("""
            <root>
                <item>First</item>
                <item>Second</item>
            </root>
            """)

        #expect(String(doc.root["item"]) == "First")
        #expect(String(doc.root[0]) == "First")
        #expect(String(doc.root[1]) == "Second")
    }

    @Test("Safe chaining with null elements")
    func safeChaining() throws {
        let doc = try XML.parse("<root/>")

        #expect(doc.root.nonexistent.isNull)
        #expect(doc.root.nonexistent.child.isNull)
        #expect(doc.root.nonexistent.optional == nil)
        #expect(doc.root[99].isNull)
    }

    @Test("Serialize accessor")
    func serializeAccessor() throws {
        let doc = try XML.parse("<root><item>Hello</item></root>")

        let string = doc.root.serialize()
        #expect(string.contains("<root>"))
        #expect(string.contains("<item>"))

        let bytes = doc.root.serialize.bytes()
        #expect(!bytes.isEmpty)
    }

    @Test("Element creation")
    func elementCreation() {
        let xml = XML.element("item", text: "Hello")
        #expect(xml.element.name == "item")
        #expect(String(xml) == "Hello")
    }

    @Test("Element with children")
    func elementWithChildren() {
        let xml = XML.element("root", children: [
            XML.element("item", text: "First"),
            XML.element("item", text: "Second")
        ])

        #expect(xml.children().count == 2)
        #expect(String(xml[0]) == "First")
        #expect(String(xml[1]) == "Second")
    }

    @Test("AllText collects nested text")
    func allTextCollectsNested() throws {
        let doc = try XML.parse("<root>Hello <b>World</b>!</root>")
        #expect(doc.root.text.all == "Hello World!")
    }

    @Test("Count property")
    func countProperty() throws {
        let doc = try XML.parse("""
            <root>
                <a/><b/><c/>
            </root>
            """)
        #expect(doc.root.count == 3)
    }

    @Test("Qualified name access")
    func qualifiedNameAccess() throws {
        let doc = try XML.parse("""
            <root xmlns:ex="http://example.com">
                <ex:item>Hello</ex:item>
            </root>
            """)

        let item = doc.root.children.first["ex:item"]
        #expect(item?.element.prefix == "ex")
        #expect(item?.element.name == "item")
        #expect(item?.element.qualified == "ex:item")
    }
}

@Suite("XML.Serializable Tests")
struct SerializableTests {
    @Test("String serialization")
    func stringSerialization() throws {
        let value = "Hello"
        let xml = value.xml
        #expect(String(xml) == "Hello")

        let restored = try String(xml: xml)
        #expect(restored == value)
    }

    @Test("Int serialization")
    func intSerialization() throws {
        let value = 42
        let xml = value.xml
        #expect(String(xml) == "42")

        let restored = try Int(xml: xml)
        #expect(restored == value)
    }

    @Test("Double serialization")
    func doubleSerialization() throws {
        let value = 3.14
        let xml = value.xml
        #expect(String(xml) == "3.14")

        let restored = try Double(xml: xml)
        #expect(restored == value)
    }

    @Test("Bool serialization")
    func boolSerialization() throws {
        let trueXML = true.xml
        let falseXML = false.xml

        #expect(trueXML.element.name == "true")
        #expect(falseXML.element.name == "false")

        #expect(try Bool(xml: trueXML) == true)
        #expect(try Bool(xml: falseXML) == false)
    }

    @Test("Array serialization")
    func arraySerialization() throws {
        let values = [1, 2, 3]
        let xml = values.xml
        #expect(xml.children().count == 3)

        let restored = try [Int](xml: xml)
        #expect(restored == values)
    }

    @Test("Optional serialization")
    func optionalSerialization() throws {
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

    @Test("xmlString convenience")
    func xmlStringConvenience() {
        let value = 42
        let string = value.xmlString()
        #expect(string.contains("42"))
    }

    @Test("xmlBytes convenience")
    func xmlBytesConvenience() {
        let value = 42
        let bytes = value.xmlBytes()
        #expect(!bytes.isEmpty)
    }
}

@Suite("XML Literal Tests")
struct LiteralTests {
    @Test("String literal")
    func stringLiteral() {
        let xml: XML = "<item>Hello</item>"
        #expect(xml.element.name == "item")
        #expect(String(xml) == "Hello")
    }

    @Test("String interpolation with escaping")
    func stringInterpolation() {
        let name = "John <Doe>"
        let xml: XML = "<name>\(name)</name>"
        #expect(String(xml) == "John <Doe>")
    }

    @Test("Interpolation escapes special characters")
    func interpolationEscapes() {
        let value = "A & B < C > D"
        let xml: XML = "<data>\(value)</data>"
        #expect(String(xml) == "A & B < C > D")
    }
}

@Suite("XML.Document Tests")
struct DocumentTests {
    @Test("Document root access")
    func documentRootAccess() throws {
        let doc = try XML.parse("<root><child/></root>")
        #expect(doc.root.element.name == "root")
    }

    @Test("Document dynamic member lookup")
    func documentDynamicMemberLookup() throws {
        let doc = try XML.parse("<root><child>Hello</child></root>")
        #expect(String(doc.root.child) == "Hello")
    }
}
