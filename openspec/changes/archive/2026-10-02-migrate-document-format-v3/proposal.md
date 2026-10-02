## Why

The `.nlist` format must persist mirror elements without duplicating the data owned by their original items. The existing version 2 format can only encode original items, while older documents must remain openable and saveable after migration.

## What Changes

- **BREAKING**: Introduce `.nlist` format version `3.0.0` for documents that may contain mirrors.
- Encode original nodes using the existing item fields and encode mirrors using their own `uuid` plus a `reference` UUID to the original item.
- Preserve mirror invariants in persisted data: references target originals in the same document, mirror IDs are globally unique, and mirrors are leaves.
- Read supported version 1 and version 2 documents and migrate them in memory to the version 3 model.
- Save documents using version `3.0.0`, preserving ordinary item content and hierarchy order.
- Reject unsupported newer major versions and malformed mirror records using the existing document errors.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `document-format`: Add version `3.0.0`, mirror node encoding, migration from versions 1 and 2, and validation of persisted mirror references.
- `data-model/mirrors`: Move mirror support from future-facing behavior into the persisted document model while retaining the existing mirror semantics and invariants.

## Impact

- `CoreModule`: document models, Codable representations, JSON provider, versioning, migration, and tests.
- `Hierarchy`: integration of the existing mirror-capable store with document persistence.
- iOS, iPadOS, and macOS: all document-based targets consume the shared format; no platform-specific file format is planned.
- Existing `.nlist` files remain readable; files containing mirrors will only be fully understood by version 3-capable applications.
