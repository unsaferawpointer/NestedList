## 1. Versioning and persisted model

- [x] 1.1 Raise the supported `.nlist` last version to `3.0.0` and keep version 1 and version 2 reads accepted
- [x] 1.2 Introduce a document persistence value that distinguishes original item content from mirror UUID/reference data
- [x] 1.3 Adapt document tree conversion so version 3 values are loaded into the existing mirror-capable hierarchy store without changing public resolved-item behavior

## 2. Encoding and migration

- [x] 2.1 Encode original nodes with the existing item fields and mirror nodes with `uuid` plus `reference`, omitting duplicated mirror content
- [x] 2.2 Preserve the existing version 1 appearance migration and convert version 1 and version 2 original-only trees into the version 3-capable model
- [x] 2.3 Ensure every save, including a document opened from an older version, writes the `3.0.0` envelope while preserving hierarchy order and document/item properties

## 3. Validation and error handling

- [x] 3.1 Validate globally unique original and mirror identifiers during version 3 decoding
- [x] 3.2 Validate that every mirror references an existing original directly and that mirrors contain no children
- [x] 3.3 Map malformed mirror records and invalid version 3 content to `unexpectedFormat`, while retaining `unknownVersion` for newer unsupported major versions

## 4. Tests and fixtures

- [x] 4.1 Add a valid version 3 fixture containing originals, nested items, and mirrors
- [x] 4.2 Add invalid version 3 fixtures for missing references, mirror-to-mirror references, duplicate identifiers, and children under mirrors
- [x] 4.3 Add round-trip tests proving mirror references are persisted without duplicated content and hierarchy order is preserved
- [x] 4.4 Add migration tests proving version 1 and version 2 fixtures remain readable and are saved as version `3.0.0`
- [x] 4.5 Run focused CoreModule and Hierarchy test suites and verify document lifecycle behavior on iOS, iPadOS, and macOS targets

## 5. Generic nodes and tagged v3 containers

- [x] 5.1 Generalize `DocumentNode` over its value type and remove `PersistedDocumentNode.swift`
- [x] 5.2 Add Codable support for `Container<ItemContent, UUID>` using explicit `item` and `mirror` tags
- [x] 5.3 Decode version 3 documents as `DocumentNode<Container<ItemContent, UUID>>` and keep v1/v2 migration routed by the document version
- [x] 5.4 Update version 3 fixtures to the tagged container format
- [x] 5.5 Extend round-trip and migration tests for tagged originals, tagged mirrors, and legacy reads
