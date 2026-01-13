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

        #expect(doc.root.user.name.get.text == "John")
        #expect(doc.root.user.email.get.text == "john@example.com")
    }

    @Test("Get accessor")
    func getAccessor() throws {
        let doc = try XML.parse(#"<root id="123" class="test"><item>Hello</item></root>"#)

        #expect(doc.root.get.name == "root")
        #expect(doc.root.get.attribute("id") == "123")
        #expect(doc.root.get.attributes["class"] == "test")
        #expect(doc.root.item.get.text == "Hello")
        #expect(doc.root.get.children.count == 1)
    }

    @Test("Query accessor")
    func queryAccessor() throws {
        let doc = try XML.parse("""
            <root>
                <item>First</item>
                <item>Second</item>
                <item>Third</item>
                <nested><item>Nested</item></nested>
            </root>
            """)

        #expect(doc.root.query.children("item").count == 3)
        #expect(doc.root.query.child("item")?.get.text == "First")
        #expect(doc.root.query.descendants("item").count == 4)
        #expect(doc.root.query.descendant("nested")?.get.name == "nested")
    }

    @Test("Subscript access")
    func subscriptAccess() throws {
        let doc = try XML.parse("""
            <root>
                <item>First</item>
                <item>Second</item>
            </root>
            """)

        #expect(doc.root["item"].get.text == "First")
        #expect(doc.root[0].get.text == "First")
        #expect(doc.root[1].get.text == "Second")
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
        #expect(xml.get.name == "item")
        #expect(xml.get.text == "Hello")
    }

    @Test("Element with children")
    func elementWithChildren() {
        let xml = XML.element("root", children: [
            XML.element("item", text: "First"),
            XML.element("item", text: "Second")
        ])

        #expect(xml.get.children.count == 2)
        #expect(xml[0].get.text == "First")
        #expect(xml[1].get.text == "Second")
    }

    @Test("AllText collects nested text")
    func allTextCollectsNested() throws {
        let doc = try XML.parse("<root>Hello <b>World</b>!</root>")
        #expect(doc.root.get.allText == "Hello World!")
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

        let item = doc.root.query.child("ex:item")
        #expect(item?.get.prefix == "ex")
        #expect(item?.get.name == "item")
        #expect(item?.get.qualified == "ex:item")
    }
}

@Suite("XML.Serializable Tests")
struct SerializableTests {
    @Test("String serialization")
    func stringSerialization() throws {
        let value = "Hello"
        let xml = value.xml
        #expect(xml.get.text == "Hello")

        let restored = try String(xml: xml)
        #expect(restored == value)
    }

    @Test("Int serialization")
    func intSerialization() throws {
        let value = 42
        let xml = value.xml
        #expect(xml.get.text == "42")

        let restored = try Int(xml: xml)
        #expect(restored == value)
    }

    @Test("Double serialization")
    func doubleSerialization() throws {
        let value = 3.14
        let xml = value.xml
        #expect(xml.get.text == "3.14")

        let restored = try Double(xml: xml)
        #expect(restored == value)
    }

    @Test("Bool serialization")
    func boolSerialization() throws {
        let trueXML = true.xml
        let falseXML = false.xml

        #expect(trueXML.get.name == "true")
        #expect(falseXML.get.name == "false")

        #expect(try Bool(xml: trueXML) == true)
        #expect(try Bool(xml: falseXML) == false)
    }

    @Test("Array serialization")
    func arraySerialization() throws {
        let values = [1, 2, 3]
        let xml = values.xml
        #expect(xml.get.children.count == 3)

        let restored = try [Int](xml: xml)
        #expect(restored == values)
    }

    @Test("Optional serialization")
    func optionalSerialization() throws {
        let some: Int? = 42
        let none: Int? = nil

        let someXML = some.xml
        let noneXML = none.xml

        #expect(someXML.get.text == "42")
        #expect(noneXML.get.name == "null")

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
        #expect(xml.get.name == "item")
        #expect(xml.get.text == "Hello")
    }

    @Test("String interpolation with escaping")
    func stringInterpolation() {
        let name = "John <Doe>"
        let xml: XML = "<name>\(name)</name>"
        #expect(xml.get.text == "John <Doe>")
    }

    @Test("Interpolation escapes special characters")
    func interpolationEscapes() {
        let value = "A & B < C > D"
        let xml: XML = "<data>\(value)</data>"
        #expect(xml.get.text == "A & B < C > D")
    }
}

@Suite("XML.Document Tests")
struct DocumentTests {
    @Test("Document root access")
    func documentRootAccess() throws {
        let doc = try XML.parse("<root><child/></root>")
        #expect(doc.root.get.name == "root")
    }

    @Test("Document dynamic member lookup")
    func documentDynamicMemberLookup() throws {
        let doc = try XML.parse("<root><child>Hello</child></root>")
        #expect(doc.root.child.get.text == "Hello")
    }
}
