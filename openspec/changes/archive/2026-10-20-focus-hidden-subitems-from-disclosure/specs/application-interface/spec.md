## ADDED Requirements

### Requirement: Disclosure arrow focuses hidden subitems in the current macOS window
In a macOS content outline, the system SHALL display a trailing disclosure arrow for an item whose subitems are hidden. Selecting that arrow SHALL focus the current content presentation on the item rather than opening a child window. The focused presentation SHALL show the item's visible descendants as root-level rows and retain the document and item-navigation behavior of the current window. Opening a child window SHALL remain available only through the explicit `Open in New Window` command.

#### Scenario: Focus hidden subitems from a document window
- **WHEN** the user selects the trailing disclosure arrow of an item with hidden subitems in a macOS document window
- **THEN** the current window focuses on that item
- **AND THEN** no additional window is opened
- **AND THEN** the outline displays the item's visible descendants as root-level rows

#### Scenario: Focus hidden subitems with no visible descendants
- **WHEN** the user selects the trailing disclosure arrow of an item with hidden subitems and no visible descendants
- **THEN** the current window focuses on that item
- **AND THEN** the window displays the existing empty-list placeholder
- **AND THEN** the item-navigation path remains available

#### Scenario: Open a child window explicitly
- **WHEN** an item with hidden subitems is selected and the user chooses `Open in New Window`
- **THEN** the application opens a focused child window for that item
- **AND THEN** selecting the item's trailing disclosure arrow is not required to open that window
