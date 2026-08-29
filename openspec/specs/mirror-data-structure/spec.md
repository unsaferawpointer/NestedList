# mirror-data-structure Specification

## Purpose

Defines a future-facing domain hierarchy that can represent original items and leaf mirror references while preserving the existing tree behavior. Mirror functionality is not currently available in NestedList; this capability establishes the data invariants and operation semantics for future use without introducing user-facing behavior or changing the current `.nlist` document format.

## Requirements

### Requirement: Future-facing hierarchy compatibility
The system SHALL treat an existing hierarchy containing only original items as a valid subset of the mirror-capable hierarchy. Introducing the mirror-capable structure SHALL NOT require existing hierarchies to contain mirrors, SHALL NOT make Mirror functionality available in the current product, and SHALL NOT by itself change the current `.nlist` document format.

#### Scenario: Use the hierarchy before Mirror functionality is introduced
- **WHEN** the application operates on a hierarchy created by the current product
- **THEN** the hierarchy contains only original items and retains its existing parent-child relationships and sibling order

#### Scenario: Preserve the current document format
- **WHEN** the mirror-capable domain structure is introduced without a separate document-format change
- **THEN** current `.nlist` documents continue to represent only original items using the existing format

### Requirement: Original and mirror element kinds
The system SHALL represent each hierarchy element as exactly one of the following kinds:

- An original item that owns its item data and ordered child elements.
- A mirror item that owns a distinct element identifier and a reference to an original item.

An original item SHALL occur exactly once as an original within a hierarchy. A mirror SHALL NOT own an independent copy of the referenced original's item data.

#### Scenario: Represent an original item
- **WHEN** an original item is added to the hierarchy
- **THEN** it owns its item data and may own an ordered collection of child elements

#### Scenario: Represent a mirror item
- **WHEN** a mirror is added to the hierarchy
- **THEN** it has its own element identifier and identifies the original item from which its data is derived

### Requirement: Globally unique element identities
The system SHALL maintain one identity namespace for original and mirror elements within a hierarchy. Every original and mirror identifier SHALL be unique, and a mirror identifier SHALL NOT equal the identifier of its referenced original.

The system SHALL reject ambiguous duplicate identities rather than silently changing an original identifier when doing so could change the meaning of a mirror reference.

#### Scenario: Accept unique identities
- **WHEN** every original and mirror has a distinct identifier
- **THEN** the hierarchy satisfies the identity invariant

#### Scenario: Reject a duplicate identity
- **WHEN** an original or mirror identifier duplicates another element identifier
- **THEN** the hierarchy is rejected without silently changing the identity of an original item

### Requirement: Direct and valid mirror references
A mirror SHALL reference an existing original item in the same hierarchy. A mirror SHALL NOT reference another mirror. When a mirror is derived from an existing mirror, the new mirror SHALL reference the same original item directly.

#### Scenario: Reference an original item
- **WHEN** a mirror references an existing original in the same hierarchy
- **THEN** the reference satisfies the target invariant

#### Scenario: Reject a missing target
- **WHEN** a mirror references an identifier that does not identify an existing original
- **THEN** the hierarchy is rejected as invalid

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
A mirror SHALL NOT contain child elements and SHALL NOT be used as the parent of another element. A mirror reference SHALL NOT contribute parent-child relationships to the hierarchy.

#### Scenario: Preserve a mirror as a leaf
- **WHEN** a valid mirror is present in the hierarchy
- **THEN** it has no child elements

#### Scenario: Reject a child under a mirror
- **WHEN** an operation would add or move an element under a mirror
- **THEN** the operation is rejected without changing the hierarchy

### Requirement: Mirrors cannot reference physical ancestors
A mirror SHALL NOT reference an original item that is a physical ancestor of that mirror. Physical ancestors SHALL be determined exclusively through parent-child relationships; mirror references SHALL NOT be traversed when determining ancestry.

The system SHALL preserve this invariant when a mirror is created, when a hierarchy or subtree is inserted, and when any original or mirror is moved.

#### Scenario: Reject a mirror of its parent
- **WHEN** a mirror would reference its original parent
- **THEN** the operation is rejected without changing the hierarchy

#### Scenario: Reject a mirror of a higher ancestor
- **WHEN** a mirror would reference any original above its parent in the physical ancestor chain
- **THEN** the operation is rejected without changing the hierarchy

#### Scenario: Reject a move that introduces an ancestor reference
- **WHEN** moving a subtree would place one of its mirrors below that mirror's referenced original
- **THEN** the entire move is rejected without changing the hierarchy

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

#### Scenario: Reject moving a mirror below its original
- **WHEN** a mirror would be moved into the physical subtree of its referenced original
- **THEN** the move is rejected without changing the hierarchy

### Requirement: Mirror deletion semantics
Deleting a mirror SHALL remove only that mirror. The referenced original and all other mirrors of that original SHALL remain in the hierarchy.

#### Scenario: Delete one mirror
- **WHEN** a mirror is deleted
- **THEN** that mirror is removed and its referenced original and all other mirrors of that original remain unchanged

### Requirement: Original deletion semantics
Deleting an original SHALL delete its entire physical subtree and every mirror anywhere in the hierarchy that references the deleted original or any original descendant in the deleted subtree.

A mirror located inside the deleted subtree SHALL be deleted as part of that subtree. An original referenced by such an internal mirror SHALL remain unless that original is itself part of the deleted subtree. The deletion SHALL be atomic and SHALL leave no mirror that references a deleted original.

#### Scenario: Delete an original with external mirrors
- **WHEN** an original is deleted while mirrors elsewhere reference it
- **THEN** the original, its physical subtree, and all mirrors of deleted originals are removed atomically

#### Scenario: Preserve an externally owned original
- **WHEN** the deleted subtree contains a mirror of an original outside that subtree
- **THEN** the internal mirror is deleted with the subtree and the external original remains

#### Scenario: Delete mirrors of original descendants
- **WHEN** an original subtree is deleted and mirrors elsewhere reference original descendants in that subtree
- **THEN** those mirrors are also deleted

### Requirement: Hierarchy state validation
The system SHALL accept a mirror-capable hierarchy only when all of the following invariants hold:

- The physical hierarchy is a forest of ordered trees.
- Each element occurs in the physical hierarchy no more than once.
- Every original and mirror identifier is unique.
- Every mirror references an existing original in the same hierarchy.
- No mirror references another mirror.
- Every mirror is a leaf.
- No mirror references one of its physical ancestors.

The system SHALL validate the resulting state before committing a structural operation. Invalid structural operations SHALL be rejected atomically. Invalid or ambiguous mirror references SHALL NOT be repaired by silently retargeting a mirror or changing an original identifier.

#### Scenario: Accept a valid original-only hierarchy
- **WHEN** a hierarchy contains only uniquely identified original items arranged as ordered trees
- **THEN** it is accepted as a valid mirror-capable hierarchy

#### Scenario: Reject an invalid mirror-capable hierarchy
- **WHEN** any identity, reference, leaf, ancestry, or physical-tree invariant is violated
- **THEN** the hierarchy is rejected without exposing a partially accepted state
