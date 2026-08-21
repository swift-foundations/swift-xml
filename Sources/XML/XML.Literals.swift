import W3C_XML

extension XML: ExpressibleByStringLiteral {

    @inlinable
    public init(stringLiteral value: String) {
        do throws(Self.Error) {
            self = try Self.fragment(value)
        } catch {
            preconditionFailure("Invalid XML literal: \(error)")
        }
    }
}

extension XML: ExpressibleByStringInterpolation {
    public struct StringInterpolation: StringInterpolationProtocol {
        @usableFromInline
        var result: String = ""

        @inlinable
        public init(literalCapacity: Int, interpolationCount: Int) {
            result.reserveCapacity(literalCapacity)
        }
    }

    @inlinable
    public init(stringInterpolation: StringInterpolation) {
        do throws(Self.Error) {
            self = try Self.fragment(stringInterpolation.result)
        } catch {
            preconditionFailure("Invalid XML literal: \(error)")
        }
    }
}

extension XML.StringInterpolation {
    @inlinable
    public mutating func appendLiteral(_ literal: String) {
        result += literal
    }

    @inlinable
    public mutating func appendInterpolation(_ value: String) {

        result += W3C_XML.Entity.escapeText(value)
    }

    @inlinable
    public mutating func appendInterpolation(raw value: String) {

        result += value
    }

    @inlinable
    public mutating func appendInterpolation(_ value: XML) {
        result += value.serialize()
    }

    @inlinable
    public mutating func appendInterpolation<T: XML.Serializable>(_ value: T) {
        result += value.xml.serialize()
    }
}
