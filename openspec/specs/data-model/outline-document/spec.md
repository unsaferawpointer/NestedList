# outline-document Specification

## Purpose

Defines the platform-independent data model of a NestedList outline document and its items, independently of the persisted `.nlist` representation.

## Requirements

### Requirement: Outline document content
The system SHALL represent an outline document as a document view and an ordered hierarchy of root items. The document MAY carry a UUID that identifies it independently of its filename or location. A restored document SHALL remain valid when no readable document UUID is available.

#### Scenario: Represent an identified document
- **WHEN** document content has a UUID
- **THEN** the data model associates that UUID with the document content

#### Scenario: Represent a document without an identifier
- **WHEN** document content is restored without a readable UUID
- **THEN** the data model retains the document view and item hierarchy without a document UUID

### Requirement: Item identity and content
Each outline item SHALL own a UUID, text, option state, and item view. An item MAY also own a note, icon, and tint color.

#### Scenario: Represent an item with optional content
- **WHEN** an item has a note, icon, or tint color
- **THEN** the data model associates the available optional content with that item

#### Scenario: Represent an item without optional content
- **WHEN** an item has no note, icon, or tint color
- **THEN** the item remains valid without those optional values

### Requirement: List-only presentation state
The system SHALL use `list` as the only document and item presentation state. The data model and persisted `.nlist` representation SHALL NOT contain a `columns` state.

#### Scenario: Create a document or item
- **WHEN** a document or item is created or restored
- **THEN** it uses the list presentation state

#### Scenario: Encode a document
- **WHEN** a document is encoded to the `.nlist` format
- **THEN** its document and item data contain no `columns` view value

### Requirement: Item option semantics
The item option state SHALL represent whether the item uses strikethrough and whether its subitems are hidden.

#### Scenario: Represent strikethrough
- **WHEN** an item's strikethrough option is enabled
- **THEN** the data model identifies the item as struck through

#### Scenario: Represent hidden subitems
- **WHEN** an item's hidden-subitems option is enabled
- **THEN** the data model identifies the item's descendants as hidden from the outline presentation
