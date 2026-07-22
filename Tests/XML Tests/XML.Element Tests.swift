import Testing

@testable import XML

@Test
func `element construction preserves and escapes ordered attributes`() {
    let xml = XML.element(
        "FileRef",
        attributes: [
            .init(name: "location", value: "group:a&b"),
            .init(name: "kind", value: "package")
        ]
    )

    #expect(xml.serialize() == "<FileRef location=\"group:a&amp;b\" kind=\"package\"/>")
}
