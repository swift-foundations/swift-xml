/// Direct access to element name properties.

// MARK: - Element Name

extension XML {
    /// Element name (local part only).
    @inlinable
    public var name: String {
        raw.name.local
    }

    /// Qualified element name (prefix:local).
    @inlinable
    public var qualifiedName: String {
        raw.name.qualified
    }

    /// Namespace prefix, if any.
    @inlinable
    public var prefix: String? {
        raw.name.prefix
    }
}
