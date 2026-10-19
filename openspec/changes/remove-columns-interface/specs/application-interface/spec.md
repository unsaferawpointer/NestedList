## ADDED Requirements

### Requirement: macOS list-based primary windows
The macOS application SHALL provide list-based document and focused-item windows. Item details and appearance pickers SHALL be presented as sheets attached to a document window rather than as primary windows.

#### Scenario: Present a document window
- **WHEN** a document window is opened on macOS
- **THEN** the application presents a resizable document window with the document toolbar and a hierarchical outline in list view

#### Scenario: Open a focused item window
- **WHEN** the user opens an item in a focused window
- **THEN** the application presents a child window associated with the same document and titles it with the focused item text

#### Scenario: Present onboarding
- **WHEN** onboarding is shown on macOS
- **THEN** the application presents a resizable modal window with a hidden title, transparent title bar, feature content, and footer actions

### Requirement: macOS list document placeholders
The macOS application SHALL present the list placeholder when a document or focused item window contains no visible content.

#### Scenario: Present an empty document outline
- **WHEN** a document contains no visible items
- **THEN** the window displays the following placeholder:

| Icon | Title | Subtitle |
| --- | --- | --- |
| `plus.square.on.square` | `No items yet` | `To add a new item, click the «plus» button or use the keyboard shortcut ⌘T` |

#### Scenario: Present an empty focused item window
- **WHEN** a focused item window contains no visible descendants
- **THEN** the window displays the list placeholder

### Requirement: macOS list document toolbar
The macOS application SHALL present a document toolbar containing an item-creation control and no document-view selection controls.

#### Scenario: Present the document toolbar
- **WHEN** a document window is open
- **THEN** the application displays an enabled `New Item` control with the `plus` icon
- **AND THEN** it does not display a view switcher or a new-column control

## MODIFIED Requirements

### Requirement: System document-based interface
The application SHALL use the standard document-based application interface provided by each platform for document discovery, presentation, and window lifecycle. NestedList-specific interface requirements SHALL supplement these system surfaces rather than redefine them.

#### Scenario: Present the document-based interface
- **WHEN** the application presents document-related interface
- **THEN** responsibility for the interface is divided as follows:

| Platform | System-provided interface | NestedList-provided interface |
| --- | --- | --- |
| iOS and iPadOS | Document browser, document container, and standard document lifecycle controls | Document outline, focused item outline, toolbars, context menus, empty states, and secondary flows |
| macOS | Document window chrome, window controls, document title handling, and standard document commands | List content, focused item windows, document toolbar, context menus, and placeholders |

#### Scenario: Browse documents on iOS or iPadOS
- **WHEN** no document is open
- **THEN** the application presents the system document browser as the root document interface

#### Scenario: Present a document window on macOS
- **WHEN** a document is opened on macOS
- **THEN** the application presents its content within a standard macOS document window

## REMOVED Requirements

### Requirement: Columns interface platform availability
**Reason**: Columns are no longer a supported document interface on any application platform.

**Migration**: No migration is required because no Columns-enabled version was released.

### Requirement: macOS primary windows
**Reason**: The requirement includes the removed columns window scenario and is superseded by the list-based primary windows requirement.

**Migration**: No migration is required because no Columns-enabled version was released.

### Requirement: macOS document placeholders
**Reason**: The requirement includes the removed columns empty state and is superseded by the list document placeholders requirement.

**Migration**: No migration is required because no Columns-enabled version was released.

### Requirement: macOS document toolbar
**Reason**: The requirement includes the removed view switcher and new-column control and is superseded by the list document toolbar requirement.

**Migration**: No migration is required because no Columns-enabled version was released.
