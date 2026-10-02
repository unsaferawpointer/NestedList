## MODIFIED Requirements

### Requirement: Mirror capability availability
The mirror-capable behavior defined by this specification SHALL be available to the document model and persistence layer. The product SHALL be able to read, preserve, and expose valid mirrors to downstream document and hierarchy behavior. User-facing mirror creation and editing controls remain outside the scope of this format migration unless separately introduced.

#### Scenario: Read a document containing mirrors
- **WHEN** a valid version 3 document contains a mirror
- **THEN** the document model restores that mirror and its reference

#### Scenario: Operate on an original-only document
- **WHEN** the application operates on a document containing only original items
- **THEN** it preserves the existing original-item behavior and hierarchy

#### Scenario: Use the current product
- **WHEN** a user creates or edits an outline with the current product
- **THEN** the available hierarchy behavior uses original items only unless mirror behavior is separately exposed

#### Scenario: Interpret the mirror requirements
- **WHEN** a mirror-specific requirement is evaluated before mirror controls are introduced
- **THEN** it defines the domain and persistence behavior rather than requiring a new user-facing control

### Requirement: Future-facing hierarchy compatibility
The system SHALL treat a hierarchy containing only original items as a valid subset of the mirror-capable hierarchy. Introducing persisted mirror support SHALL NOT require existing documents to contain mirrors, and reading or saving an original-only document SHALL preserve its parent-child relationships and sibling order.

#### Scenario: Read an existing original-only hierarchy
- **WHEN** the application opens a valid version 1 or version 2 document
- **THEN** it restores the hierarchy as original items in the version 3-capable model

#### Scenario: Save an original-only hierarchy
- **WHEN** the application saves a hierarchy that contains no mirrors
- **THEN** it writes a valid version 3 document without adding mirror records

#### Scenario: Use the hierarchy before Mirror functionality is introduced
- **WHEN** the application operates on a hierarchy created by the current product
- **THEN** the hierarchy contains only original items and retains its existing parent-child relationships and sibling order

#### Scenario: Preserve the current document format
- **WHEN** the mirror-capable domain structure is used with an original-only document
- **THEN** the document remains representable without mirror records

### Requirement: Original and mirror element kinds
The system SHALL represent each hierarchy element as exactly one of the following kinds:

- An original item that owns its item data and ordered child elements.
- A mirror item that owns a distinct element identifier and a reference to an original item.

An original item SHALL occur exactly once as an original within a hierarchy. A mirror SHALL NOT own an independent copy of the referenced original's item data. These distinctions SHALL be preserved when the hierarchy is persisted and restored.

#### Scenario: Persist an original item
- **WHEN** an original item is saved
- **THEN** its item data is encoded with its own identifier and can include ordered children

#### Scenario: Persist a mirror item
- **WHEN** a mirror is saved
- **THEN** only its element identifier and original reference are persisted as mirror data

#### Scenario: Represent an original item
- **WHEN** an original item is added to the hierarchy
- **THEN** it owns its item data and may own an ordered collection of child elements

#### Scenario: Represent a mirror item
- **WHEN** a mirror is added to the hierarchy
- **THEN** it has its own element identifier and identifies the original item from which its data is derived

### Requirement: Direct and valid mirror references
A mirror SHALL reference an existing original item in the same hierarchy. A mirror SHALL NOT reference another mirror. When a mirror is derived from an existing mirror, the new mirror SHALL reference the same original item directly.

#### Scenario: Restore a direct reference
- **WHEN** a mirror references an existing original item in the same hierarchy
- **THEN** the reference is accepted and the mirror resolves to the original's current data

#### Scenario: Reject a missing target
- **WHEN** a persisted mirror references an identifier that does not identify an original
- **THEN** the document is rejected without producing a partially restored hierarchy

#### Scenario: Reject an indirect reference
- **WHEN** a persisted mirror references another mirror
- **THEN** the document is rejected without producing a partially restored hierarchy

#### Scenario: Reference an original item
- **WHEN** a mirror references an existing original item in the same hierarchy
- **THEN** the reference satisfies the target invariant

#### Scenario: Reject creation with a missing target
- **WHEN** an operation attempts to create a mirror for an identifier that does not identify an existing original
- **THEN** the operation is rejected without changing the hierarchy

#### Scenario: Derive a mirror from another mirror
- **WHEN** a mirror is derived from an existing mirror
- **THEN** the new mirror references the existing mirror's original item rather than the existing mirror itself

### Requirement: Mirrors are leaf elements
A mirror SHALL NOT contain child elements and SHALL NOT be used as the parent of another element. A mirror reference SHALL NOT contribute parent-child relationships to the hierarchy. This invariant SHALL be enforced when reading persisted documents.

#### Scenario: Restore a valid mirror leaf
- **WHEN** a persisted mirror has no children
- **THEN** it is restored as a leaf element

#### Scenario: Reject a persisted mirror with children
- **WHEN** a persisted mirror contains child elements
- **THEN** document reading fails with an invalid-format error

#### Scenario: Preserve a mirror as a leaf
- **WHEN** a valid mirror is present in the hierarchy
- **THEN** it has no child elements

#### Scenario: Reject a child under a mirror
- **WHEN** an operation would add or move an element under a mirror
- **THEN** the operation is rejected without changing the hierarchy
