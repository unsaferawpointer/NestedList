# mirrors Specification

## Purpose

Defines the mirror extension to the outline data model: original items, leaf mirror references, their invariants, and their structural operation semantics.

## Requirements

### Requirement: Mirror capability availability
The mirror-capable behavior SHALL be available to the document model and persistence layer. The product SHALL be able to read, preserve, and expose valid mirrors to downstream document and hierarchy behavior. User-facing mirror creation and editing controls remain outside the scope of this format migration unless separately introduced.

#### Scenario: Read a document containing mirrors
- **WHEN** a valid version 3 document contains a mirror
- **THEN** the document model restores that mirror and its reference

#### Scenario: Operate on an original-only document
- **WHEN** the application operates on a document containing only original items
- **THEN** it preserves the existing original-item behavior and hierarchy

#### Scenario: Use the current product
- **WHEN** a user creates or edits an outline with the current product
- **THEN** the available hierarchy behavior uses original items only unless mirror behavior is separately exposed

### Requirement: Future-facing hierarchy compatibility
The system SHALL treat a hierarchy containing only original items as a valid subset of the mirror-capable hierarchy. Introducing persisted mirror support SHALL NOT require existing documents to contain mirrors, and reading or saving an original-only document SHALL preserve its parent-child relationships and sibling order.

#### Scenario: Read an existing original-only hierarchy
- **WHEN** the application opens a valid version 1 or version 2 document
- **THEN** it restores the hierarchy as original items in the version 3-capable model

#### Scenario: Save an original-only hierarchy
- **WHEN** the application saves a hierarchy that contains no mirrors
- **THEN** it writes a valid version 3 document without adding mirror records

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

### Requirement: Globally unique element identities
The system SHALL maintain one identity namespace for original and mirror elements within the stored hierarchy. Every stored original and mirror identifier SHALL be unique, and a mirror identifier SHALL NOT equal the identifier of its referenced original.

When a new tree is inserted, duplicate identifiers within that incoming tree SHALL be rejected. When an incoming identifier conflicts with an identifier already stored in the hierarchy, the system SHALL assign the incoming element a new unused identifier and SHALL update references within the incoming tree that target the replaced identifier. Existing elements and their identifiers SHALL remain unchanged.

#### Scenario: Accept unique identities
- **WHEN** every original and mirror has a distinct identifier
- **THEN** the hierarchy satisfies the identity invariant

#### Scenario: Reject a duplicate identity within an inserted tree
- **WHEN** two elements in the same incoming tree have the same identifier
- **THEN** the insertion is rejected with a duplicate-identifier error and the hierarchy remains unchanged

#### Scenario: Regenerate an identifier that conflicts with stored state
- **WHEN** an incoming element has an identifier already used by a stored element
- **THEN** the incoming element receives a new unused identifier, references in the incoming tree are updated accordingly, and the stored element retains its identifier and data

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

#### Scenario: Derive a mirror from another mirror
- **WHEN** a mirror is derived from an existing mirror
- **THEN** the new mirror references the existing mirror's original item rather than the existing mirror itself

### Requirement: Mirror value semantics
The item data associated with a mirror SHALL be the item data owned by its referenced original. Reading item data through a mirror SHALL yield the referenced original's current data. Changing item data through a mirror SHALL change the referenced original's data and SHALL NOT create mirror-specific item data.

#### Scenario: Read data through a mirror
- **WHEN** item data is requested for a mirror
- **THEN** the current data owned by the referenced original is returned

#### Scenario: Change data through a mirror
- **WHEN** item data is changed through a mirror
- **THEN** the referenced original owns the changed data and the mirror remains a reference without independent item data

### Requirement: Mirrors are leaf elements
A mirror SHALL NOT contain child elements and SHALL NOT be used as the parent of another element. A mirror reference SHALL NOT contribute parent-child relationships to the hierarchy. This invariant SHALL be enforced when reading persisted documents.

#### Scenario: Restore a valid mirror leaf
- **WHEN** a persisted mirror has no children
- **THEN** it is restored as a leaf element

#### Scenario: Reject a persisted mirror with children
- **WHEN** a persisted mirror contains child elements
- **THEN** document reading fails with an invalid-format error

#### Scenario: Reject a child under a mirror
- **WHEN** an operation would add or move an element under a mirror
- **THEN** the operation is rejected without changing the hierarchy

### Requirement: Mirrors cannot reference physical ancestors
A mirror SHALL NOT reference an original item that is a physical ancestor of that mirror. Physical ancestors SHALL be determined exclusively through parent-child relationships; mirror references SHALL NOT be traversed when determining ancestry.

#### Scenario: Reject a mirror of its parent
- **WHEN** a mirror would reference its original parent
- **THEN** the operation is rejected without changing the hierarchy

#### Scenario: Allow a reference outside the ancestor chain
- **WHEN** a mirror references an original that is not one of its physical ancestors
- **THEN** the reference satisfies the ancestry invariant

### Requirement: Original movement semantics
Moving an original SHALL move that original together with its physical subtree. Mirrors that reference the moved original or an original in its subtree but are located outside the moved subtree SHALL remain in their existing locations.

The move SHALL be rejected when it places the original inside its own physical subtree, uses a mirror as the destination parent, or causes any mirror to reference a physical ancestor.

#### Scenario: Move an original subtree
- **WHEN** an original is moved to a valid destination
- **THEN** its physical subtree moves with it and external mirrors retain their existing locations and references

#### Scenario: Reject an invalid original move
- **WHEN** moving an original would violate a parent-child or mirror ancestry invariant
- **THEN** the entire move is rejected without changing the hierarchy

### Requirement: Mirror movement semantics
Moving a mirror SHALL move only that mirror. The referenced original and every other mirror of that original SHALL retain their existing locations.

The move SHALL be rejected when it uses a mirror as the destination parent or places the mirror below its referenced original.

#### Scenario: Move only one mirror
- **WHEN** a mirror is moved to a valid destination
- **THEN** only the selected mirror changes location

### Requirement: Mirror deletion semantics
Deleting a mirror SHALL remove only that mirror. The referenced original and all other mirrors of that original SHALL remain in the hierarchy.

#### Scenario: Delete one mirror
- **WHEN** a mirror is deleted
- **THEN** that mirror is removed and its referenced original and all other mirrors of that original remain unchanged

### Requirement: Original deletion semantics
Deleting an original SHALL delete its entire physical subtree and every mirror anywhere in the hierarchy that references the deleted original or any original descendant in the deleted subtree. The deletion SHALL be atomic and SHALL leave no mirror that references a deleted original.

#### Scenario: Delete an original with external mirrors
- **WHEN** an original is deleted while mirrors elsewhere reference it
- **THEN** the original, its physical subtree, and all mirrors of deleted originals are removed atomically

#### Scenario: Preserve an externally owned original
- **WHEN** the deleted subtree contains a mirror of an original outside that subtree
- **THEN** the internal mirror is deleted with the subtree and the external original remains

### Requirement: Hierarchy state validation
The system SHALL validate the resulting stored hierarchy after initialization, insertion, and movement. A valid state SHALL satisfy all of the following conditions:

- The physical hierarchy is a forest of ordered trees.
- Every stored element has a unique identifier.
- Every mirror references an existing original in the same hierarchy.
- No mirror references another mirror.
- Every mirror is a leaf.
- Physical containment and mirror references SHALL NOT form a dependency cycle.

Initialization SHALL validate the supplied hierarchy before exposing the store. If initialization violates a condition, it SHALL fail with the corresponding validation error. Insertion and movement SHALL reject invalid states atomically.

#### Scenario: Accept a valid original-only hierarchy
- **WHEN** a hierarchy contains uniquely identified original items arranged as ordered trees
- **THEN** initialization accepts it as a valid mirror-capable hierarchy

#### Scenario: Reject an invalid hierarchy during initialization
- **WHEN** initialization encounters a duplicate identifier, invalid mirror reference, reference cycle, or mirror with children
- **THEN** initialization fails with the corresponding validation error and does not expose a partially initialized store

#### Scenario: Roll back an invalid insertion or move
- **WHEN** an insertion or move would make the resulting hierarchy invalid
- **THEN** the operation fails and the hierarchy remains unchanged
