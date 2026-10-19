## ADDED Requirements

### Requirement: List-only presentation state
The system SHALL use `list` as the only document and item presentation state. The data model and persisted `.nlist` representation SHALL NOT contain a `columns` state.

#### Scenario: Create a document or item
- **WHEN** a document or item is created or restored
- **THEN** it uses the list presentation state

#### Scenario: Encode a document
- **WHEN** a document is encoded to the `.nlist` format
- **THEN** its document and item data contain no `columns` view value

## REMOVED Requirements

### Requirement: Document and item view state
**Reason**: The requirement supports the removed `columns` state.

**Migration**: No migration is required because no document containing the Columns feature has been released.
