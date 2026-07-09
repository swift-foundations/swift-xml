/// Toolchain capability gate for the §A9 `Tagged` metadata SIGSEGV.
///
/// `XML.parse` / `XML.ND.stream` / `XML.parse(collecting:)` all route through
/// `W3C_XML.parse`, which runs the stack-safe `Parser.Machine.Parser` over
/// `Byte.Input` (= `Input.Slice<Array<Column.Shared<Byte>>>`). That input's
/// `Index` resolves to `Tagged_Primitives.Tagged<Element, Ordinal>`, so the
/// machine parser's type-metadata / `Parser.Protocol` witness-table
/// instantiation forces `Tagged`'s full value-witness table. On Swift 6.3.x
/// this triggers catalog §A9: `__swift_instantiateConcreteTypeFromMangledNameV2`
/// → `swift_getTypeByMangledName` returns `TypeLookupError("unknown error")` →
/// null-metadata deref → SIGSEGV (`EXC_BAD_ACCESS`, address 0x10), observable
/// via `SWIFT_DEBUG_FAILED_TYPE_LOOKUP=1` ("failed type lookup … unknown error").
/// The crash fires before `parse` can return or throw — even on the most trivial
/// input — so any suite that calls `XML.parse` (directly or via the async stream
/// collecting path) SIGSEGVs rather than asserting.
///
/// Root cause: incomplete `SuppressedAssociatedTypes` codegen on 6.3 (the
/// suppressed `Ordinal.Domain: ~Copyable`); the fix travels with the compiler
/// binary and is complete by 6.4-dev. There is no Institute-side code fix — the
/// raw-storage wrapper was reverted on correctness grounds (catalog §A9,
/// 2026-05-23), and the principal decision (2026-06-27) is to require Swift 6.4+
/// for `Parser.Machine.Parser<Byte.Input, …>` rather than change `Byte.Input` or
/// flatten its cursor backing. So the `parse`-exercising suites are skipped on
/// the buggy toolchain and run normally once the compiler ships the fix; the
/// guard retires when the workspace adopts Swift 6.4 (~September 2026).
///
/// This mirrors the upstream `swift-w3c-xml` gate
/// (`swift-w3c-xml/Tests/W3C XML Tests/Toolchain.swift`): swift-xml is the L3
/// consumer of the same byte-domain machine-parser surface, so it inherits the
/// same accepted stance per catalog §A9's ecosystem note ("every such site
/// inherits the same accepted stance and the September-2026 retirement trigger").
///
/// Catalog: `swift-institute/Research/swift-compiler-bug-catalog.md` §A9 and its
/// `Parser.Machine.Parser<Byte.Input, …>.parse` new-site addendum (2026-06-27).
/// Issues: `swift-institute/Issues/swift-issue-tagged-noncopyable-atomic-metadata-crash`.
enum Toolchain {
}

extension Toolchain {
    /// `true` on Swift compilers older than 6.4, where the §A9 `Tagged` metadata
    /// SIGSEGV fires. Used as the predicate for the `.disabled(if:)` trait on the
    /// `parse`-exercising suites. `.disabled(if:)` (not `withKnownIssue`) is
    /// required: a SIGSEGV kills the test runner before swift-testing can register
    /// a known issue, so only skipping the body yields a clean run on 6.3.x. The
    /// guard auto-recovers (runs the suites normally) on 6.4+.
    static var hasTaggedMetadataSIGSEGV: Bool {
        #if compiler(<6.4)
            return true
        #else
            return false
        #endif
    }
}
