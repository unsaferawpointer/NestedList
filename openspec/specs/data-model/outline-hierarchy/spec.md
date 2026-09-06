# outline-hierarchy Specification

## Purpose

Defines the platform-independent ordered hierarchy used by NestedList outline documents.

## Requirements

### Requirement: Ordered outline forest
The system SHALL represent an outline hierarchy as an ordered forest of item nodes. Each node SHALL own one item and MAY own an ordered collection of child nodes.

#### Scenario: Represent root items
- **WHEN** a document contains multiple root items
- **THEN** the hierarchy retains the order of those root items

#### Scenario: Represent nested items
- **WHEN** an item has descendant items
- **THEN** the hierarchy retains every parent-child relationship and the order of siblings at each level

### Requirement: Physical hierarchy integrity
Each node SHALL occur in the physical hierarchy no more than once. The parent-child relationships SHALL form trees without cycles, and an item SHALL NOT be placed below itself or one of its descendants.

#### Scenario: Accept a valid item hierarchy
- **WHEN** item nodes form one or more ordered trees without repeated nodes or cycles
- **THEN** the hierarchy is accepted as structurally valid

#### Scenario: Reject a cyclic placement
- **WHEN** an operation would place an item below itself or one of its descendants
- **THEN** the operation is rejected without changing the hierarchy

### Requirement: Structural operation preservation
An operation that inserts, moves, copies, or deletes items SHALL preserve the physical hierarchy integrity and the order of every unaffected sibling collection. A rejected structural operation SHALL leave the hierarchy unchanged.

#### Scenario: Move an item subtree
- **WHEN** an item is moved to a valid destination
- **THEN** the item moves together with its descendants and unaffected hierarchy relationships retain their order

#### Scenario: Reject an invalid structural operation
- **WHEN** an insertion, move, copy, or deletion would produce an invalid physical hierarchy
- **THEN** the entire operation is rejected without exposing a partially changed hierarchy

