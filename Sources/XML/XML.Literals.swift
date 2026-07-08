/// XML.Literals.swift
/// swift-xml
///
/// Literal expressibility for XML

import W3C_XML

// MARK: - String Literal

extension XML: ExpressibleByStringLiteral {
    /// Creates an XML element by parsing a string literal.
    ///
    /// - Note: This will trap if the string is not valid XML.
    @inlinable
    public init(stringLiteral value: String) {
        do throws(XML.Error) {
            self = try Self.fragment(value)
        } catch {
            preconditionFailure("Invalid XML literal: \(error)")
        }
    }
}

// MARK: - String Interpolation

extension XML: ExpressibleByStringInterpolation {
    public struct StringInterpolation: StringInterpolationProtocol {
        @usableFromInline
        var result: String = ""

        @inlinable
        public init(literalCapacity: Int, interpolationCount: Int) {
            result.reserveCapacity(literalCapacity)
        }

        @inlinable
        public mutating func appendLiteral(_ literal: String) {
            result += literal
        }

        @inlinable
        public mutating func appendInterpolation(_ value: String) {
            // Escape special characters
            result += W3C_XML.Entity.escapeText(value)
        }

        @inlinable
        public mutating func appendInterpolation(raw value: String) {
            // No escaping
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

    @inlinable
    public init(stringInterpolation: StringInterpolation) {
        do throws(XML.Error) {
            self = try Self.fragment(stringInterpolation.result)
        } catch {
            preconditionFailure("Invalid XML literal: \(error)")
        }
    }
}
