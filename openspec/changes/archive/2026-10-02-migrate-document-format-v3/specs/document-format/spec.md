## MODIFIED Requirements

### Requirement: Versioned `.nlist` document envelope
The system SHALL store a `.nlist` document as a JSON object with a `version` string and a `content` object. New documents that use the mirror-capable format SHALL write version `3.0.0`. When reading, the system SHALL accept supported version 1 and version 2 documents and migrate them in memory to the current model. The `content` object SHALL contain the document's `items` tree and MAY contain its `view` and `uuid` properties.

#### Scenario: Save a mirror-capable document
- **WHEN** the system saves a document using the version 3 format
- **THEN** it writes the versioned JSON envelope using version `3.0.0`

#### Scenario: Read a version 1 document
- **WHEN** the system opens a valid version 1 `.nlist` document
- **THEN** it restores the document and migrates its legacy item appearance into the current model

#### Scenario: Read a versioned document
- **WHEN** a `.nlist` JSON document contains a valid `version` and a valid `content.items` tree
- **THEN** the system restores its document content

#### Scenario: Save a document
- **WHEN** the system saves a `.nlist` document
- **THEN** it writes the versioned JSON envelope using version `3.0.0`

#### Scenario: Read a version with a prefix or omitted components
- **WHEN** a document version has an optional leading `v` or omits its minor or patch component
- **THEN** the system derives the missing version components as `0` and attempts to read the document

#### Scenario: Read a version 2 document
- **WHEN** the system opens a valid version 2 `.nlist` document
- **THEN** it restores the document and migrates its original items into the version 3-capable model

#### Scenario: Read a document without an envelope field
- **WHEN** a `.nlist` JSON document omits `version`, `content`, or `content.items`
- **THEN** the system rejects the document as having an unexpected format

### Requirement: Hierarchical item and mirror encoding
The `.nlist` format SHALL encode the outline hierarchy in `content.items` as an ordered array of generic document tree nodes. Each encoded tree node SHALL contain a `value` object and MAY contain a `children` array. Version `3.0.0` values SHALL use the synthesized Codable representation of the tagged `Container` enum: an original SHALL be encoded under `item` with `id` and nested `content`, while a mirror SHALL be encoded under `mirror` with `id` and `reference`. A mirror payload SHALL NOT duplicate the original item's content fields. Reading or saving the hierarchy SHALL preserve parent-child relationships and sibling order.

#### Scenario: Read a mirror node
- **WHEN** a version 3 node value contains a `mirror` payload with `id` and `reference`
- **THEN** the system restores a mirror element with the stored identifier and reference

#### Scenario: Save a mirror node
- **WHEN** a document contains a mirror element
- **THEN** the system writes a `mirror` payload containing its element `id` and original-item `reference` without duplicating the referenced item data

#### Scenario: Read an original node
- **WHEN** a version 3 node value contains an `item` payload with `id` and nested item `content`
- **THEN** the system restores an original item with its stored content

#### Scenario: Preserve a mirror as a leaf
- **WHEN** a mirror node is saved or read
- **THEN** its encoded `children` collection is empty or absent

#### Scenario: Preserve nested originals
- **WHEN** an original node contains descendant nodes in `children`
- **THEN** the system restores and saves those nodes in their stored order

### Requirement: Backward-compatible document reading
The system SHALL maintain backward compatibility with valid `.nlist` documents written in supported earlier formats on iOS, iPadOS, and macOS. It SHALL restore their hierarchy, item data, and available appearance semantics, then save documents using version `3.0.0`. Earlier-version documents contain original items only and SHALL remain valid without modification until saved.

#### Scenario: Open a legacy document
- **WHEN** the system opens a valid version 1 or version 2 document
- **THEN** it restores all supported original-item data and hierarchy relationships

#### Scenario: Save content read from a legacy document
- **WHEN** the system saves content that was read from a valid earlier document
- **THEN** it writes version `3.0.0` while preserving the content and appearance semantics

#### Scenario: Open a document in the legacy format
- **WHEN** the system opens a valid document matching a supported legacy JSON format
- **THEN** it restores the document content and its available appearance semantics

#### Scenario: Open a document in the current format
- **WHEN** the system opens a valid version 3 document matching the current JSON format
- **THEN** it restores the document content without requiring legacy-only fields

#### Scenario: Open a version 3 document containing only originals
- **WHEN** the system opens a version 3 document without mirrors
- **THEN** it restores the same original-item hierarchy and data as the equivalent earlier format

### Requirement: Persisted mirror validation
The system SHALL reject a version 3 document when a mirror has a missing reference, references another mirror, uses an identifier that is not globally unique, or has children. A version 3 document with valid mirror references SHALL be accepted and restored without changing the stored sibling order.

#### Scenario: Reject a missing mirror reference
- **WHEN** a mirror's `reference` does not identify an original item in the same document
- **THEN** the system rejects the document as having an unexpected format

#### Scenario: Reject a mirror reference to another mirror
- **WHEN** a mirror references an element whose value is itself a mirror
- **THEN** the system rejects the document as having an unexpected format

#### Scenario: Reject duplicate element identifiers
- **WHEN** two original or mirror elements use the same `uuid`
- **THEN** the system rejects the document as having an unexpected format

#### Scenario: Reject children under a mirror
- **WHEN** a mirror node contains one or more child nodes
- **THEN** the system rejects the document as having an unexpected format

### Requirement: Document format validation
The system SHALL reject a `.nlist` document whose declared major format version is newer than the application's supported version 3 with the `unknownVersion` error. It SHALL reject damaged JSON, invalid envelope data, invalid version 3 mirror data, or required fields that cannot be decoded with the `unexpectedFormat` error. Unreadable optional appearance fields and `content.uuid` SHALL NOT by themselves cause this error.

#### Scenario: Read a document newer than version 3
- **WHEN** the system opens a `.nlist` document whose declared major format version is greater than `3`
- **THEN** it rejects the document with the `unknownVersion` error

#### Scenario: Read a document newer than the application's last version
- **WHEN** the system opens a `.nlist` document whose declared major format version is greater than the application's supported version
- **THEN** it rejects the document with the `unknownVersion` error

#### Scenario: Read damaged JSON
- **WHEN** the system opens a file that is not valid JSON or has no decodable document envelope
- **THEN** it rejects the document with the `unexpectedFormat` error

#### Scenario: Read a damaged document
- **WHEN** the system opens a `.nlist` file that is not valid JSON or does not contain a decodable document envelope
- **THEN** it rejects the document with the `unexpectedFormat` error

#### Scenario: Read invalid mirror content
- **WHEN** a version 3 document contains invalid mirror relationships
- **THEN** it rejects the document with the `unexpectedFormat` error

#### Scenario: Read invalid content for its format
- **WHEN** a document's envelope version is supported but its required content structure cannot be decoded
- **THEN** it rejects the document with the `unexpectedFormat` error
