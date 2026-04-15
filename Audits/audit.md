# Audit: swift-xml

## Legacy — Consolidated 2026-04-08

### From: swift-institute/Research/modularization-audit-foundations-single-target.md (2026-03-20)

**Modularization audit — single-target packages**

#### MOD-010: StdLib Extension Isolation — 4 files

| File | Extends | API Added |
|------|---------|-----------|
| `Bool+XML.swift` | `Bool` | `init?(_ xml: XML)` |
| `Int+XML.swift` | `Int` | `init?(_ xml: XML)` |
| `Double+XML.swift` | `Double` | `init?(_ xml: XML)` |
| `String+XML.swift` | `String` | `init?(_ xml: XML)` |

Additionally, `XML.Serializable.swift` adds conformances to stdlib types. Identical pattern to swift-json.

These are domain-coupled but add public API surface to stdlib types in every consumer's namespace. An `XML StdLib Integration` module would let consumers opt in.

**Action**: Consider a `XML StdLib Integration` module.
