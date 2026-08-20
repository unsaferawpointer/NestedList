# document-lifecycle Specification

## Purpose

Defines how NestedList creates, opens, saves, and reports errors for documents across iOS, iPadOS, and macOS.

## Requirements

### Requirement: New document state
The system SHALL create a new NestedList document with a unique document UUID, no root items, and the `list` document view.

#### Scenario: Create a document from the iOS document browser
- **WHEN** a user requests a new document from the iOS or iPadOS document browser
- **THEN** the system creates and saves an empty `.nlist` document before returning it to the document browser

#### Scenario: Create a document on macOS
- **WHEN** a user creates a new document on macOS
- **THEN** the system presents an empty document with the `list` view

### Requirement: Document opening
The system SHALL load document data using the provided document type, replace the current document state with the decoded content, and make the loaded content available to the platform-specific document UI.

#### Scenario: Open a valid NestedList document
- **WHEN** a user opens a valid `.nlist` document
- **THEN** the system displays its decoded hierarchy and document view

#### Scenario: Select a document on iOS or iPadOS
- **WHEN** a user selects one or more documents in the document browser
- **THEN** the system opens the first selected document

### Requirement: Document saving
The system SHALL serialize the current document state using the requested document type when the platform saves a document. On macOS, the system SHALL support autosaving documents in place.

#### Scenario: Save a changed document
- **WHEN** the platform saves a document after its content changes
- **THEN** the saved data represents the document's current state in the requested format

#### Scenario: Autosave on macOS
- **WHEN** a macOS document has unsaved changes
- **THEN** the system allows the platform to autosave those changes in place

### Requirement: Undo history after loading
The system SHALL clear the document undo history after it successfully replaces the document state by loading data.

#### Scenario: Load a document after editing
- **WHEN** the system successfully loads document data into a document with existing undo actions
- **THEN** no undo actions from the previous state remain available

### Requirement: Document load errors
The system SHALL report a document-format loading failure to the platform as an error. On iOS and iPadOS, when user interaction is permitted, it SHALL present the error to the user.

#### Scenario: Open an invalid document on iOS or iPadOS
- **WHEN** the system cannot load a selected document because its format is invalid or unsupported
- **THEN** it reports the error and presents an alert when user interaction is permitted

#### Scenario: Open an invalid document on macOS
- **WHEN** the system cannot load a document because its format is invalid or unsupported
- **THEN** it reports the error to the macOS document system
