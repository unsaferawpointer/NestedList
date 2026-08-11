## Purpose

Defines each outline item's persisted presentation preference while preserving the readability of existing NestedList documents.

## ADDED Requirements

### Requirement: Item display preference
The system SHALL expose a display preference for every item with `list` and `columns` modes. Newly created items SHALL use `list` unless a different mode is explicitly selected.

#### Scenario: Create an item without a specified display preference
- **WHEN** a client creates an item without providing a display preference
- **THEN** the item uses the `list` mode

#### Scenario: Store an item as columns
- **WHEN** a client sets an item's display preference to `columns`
- **THEN** the item retains `columns` as its display preference

### Requirement: Item display preference persistence
The system SHALL persist an item's display preference in a `.nlist` document and SHALL restore it when the document is read on iOS, iPadOS, or macOS.

#### Scenario: Read a document containing an item display preference
- **WHEN** a `.nlist` document contains an item's `columns` display preference
- **THEN** the decoded item uses the `columns` mode

#### Scenario: Read a document created before item display preferences
- **WHEN** a `.nlist` document omits an item's display preference
- **THEN** the decoded item uses the `list` mode

### Requirement: Columns terminology for document display mode
The system SHALL expose `columns` as the document display-mode name in place of `board` while maintaining compatibility with documents previously stored using the board mode.

#### Scenario: Read a document stored with the former board mode
- **WHEN** a `.nlist` document contains the persisted value previously represented by the `board` mode
- **THEN** the decoded document uses the `columns` mode

#### Scenario: Write a document in columns mode
- **WHEN** a document using the `columns` mode is saved and read again
- **THEN** it restores with the `columns` mode
