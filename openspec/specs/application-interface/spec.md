# application-interface Specification

## Purpose

Defines the user-visible presentation of the NestedList application interface.

## Requirements

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

### Requirement: iOS primary screens
The iOS and iPadOS applications SHALL provide the following primary screens. Task-specific interfaces such as item details, icon and color pickers, move destination, and reordering SHALL be presented as secondary flows rather than primary screens.

#### Scenario: Present a primary screen
- **WHEN** the application presents a primary screen on iOS or iPadOS
- **THEN** the screen matches the following structure:

| Screen | Presentation | Primary content |
| --- | --- | --- |
| Document browser | Root system document browser | Available documents and document creation controls |
| Document outline | Root document screen in the navigation stack | Hierarchical outline with the document title and document toolbar |
| Focused item outline | Screen pushed onto the document navigation stack | Hierarchical outline of the focused item's descendants with the item title and document toolbar |
| Onboarding | Modal screen | Paged feature content with an icon, title, description, and footer actions |

#### Scenario: Navigate to a focused item outline
- **WHEN** the user opens an item as a focused outline
- **THEN** the application pushes the focused item outline onto the navigation stack and retains a back path to the previous outline

### Requirement: iOS outline empty state
The iOS and iPadOS applications SHALL present an empty state when a document outline or focused item outline contains no visible items.

#### Scenario: Present an empty outline
- **WHEN** an outline contains no visible items
- **THEN** the screen displays the following empty state:

| Icon | Title | Subtitle |
| --- | --- | --- |
| `plus.square.on.square` | `No Items` | `To add a new item, tap the '+' button` |

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

### Requirement: macOS item context menu
The macOS application SHALL present an item context menu based on the current selection. The menu SHALL always include the `Open in New Window` command. The command SHALL be disabled when no item is selected and enabled when one or more items are selected; when enabled, it SHALL open a focused child window for the first selected item in the outline's visual order.

#### Scenario: Present the context menu without a selection
- **WHEN** no items are selected
- **THEN** the context menu displays the following entries:

| Entry | Icon | Shortcut | State | Action |
| --- | --- | --- | --- | --- |
| `New Item` | `plus` | `⌘T` | Enabled | Create an item |
| `New Mirror…` | `arrow.triangle.branch` | — | Enabled | Open mirror source selection |
| Separator | — | — | — | — |
| `Open in New Window` | `macwindow.on.rectangle` | — | Disabled | — |

#### Scenario: Present the context menu with a selection
- **WHEN** one or more items are selected
- **THEN** the context menu displays the following entries in order:

| Entry | Icon | Shortcut | State | Action |
| --- | --- | --- | --- | --- |
| `New Item` | `plus` | `⌘T` | Enabled | Create an item |
| `New Mirror…` | `arrow.triangle.branch` | — | Enabled | Open mirror source selection |
| Separator | — | — | — | — |
| `Open in New Window` | `macwindow.on.rectangle` | — | Enabled | Open the first selected item in a focused child window |
| `Edit…` | `square.and.pencil` | — | Enabled | Edit item details |
| Separator | — | — | — | — |
| `Strikethrough` | — | `⌘↩` | Enabled | Toggle strikethrough |
| `Hide subitems` | — | — | Enabled | Toggle subitem visibility |
| Separator | — | — | — | — |
| `Note` | `note.text` | — | Enabled | Toggle note visibility |
| Separator | — | — | — | — |
| `Appearance` | — | — | Enabled | — |
| `Icon…` | `photo` | — | Enabled | Select an icon |
| `Color…` | `paintpalette` | — | Enabled | Select a color |
| Separator | — | — | — | — |
| `Delete` | `trash` | `⌘⌫` | Enabled | Delete selected items |

#### Scenario: Open the first item from a multiple selection
- **WHEN** the user selects `Open in New Window` while multiple items are selected
- **THEN** the application opens a focused child window for the selected item nearest the top of the outline
- **AND THEN** it does not open windows for the remaining selected items

### Requirement: iOS item context menu
The iOS application SHALL present a context menu for an outline item when the list is not in an editing mode.

#### Scenario: Present the context menu for an item
- **WHEN** the user presents the context menu for an item
- **THEN** the context menu displays the following entries in order:

| Entry | Icon | Shortcut | Action |
| --- | --- | --- | --- |
| `Cut` | `scissors` | — | Cut the item |
| `Copy` | `doc.on.doc` | — | Copy the item |
| `Paste` | `doc.on.clipboard` | — | Paste content |
| Separator | — | — | — |
| `Strikethrough` | — | — | Toggle strikethrough |
| `Hide subitems` | — | — | Toggle subitem visibility |
| Separator | — | — | — |
| `Edit…` | `pencil` | — | Edit item details |
| `New…` | `plus` | — | Create an item |
| `New Mirror…` | `arrow.triangle.branch` | — | Open mirror source selection |
| `Appearance` | `slider.horizontal.below.square.filled.and.square` | — | — |
| ↳ `Icon…` | `photo` | — | Select an icon |
| ↳ `Color…` | `paintpalette` | — | Select a color |
| Separator | — | — | — |
| `Move to…` | `arrow.left.arrow.right` | — | Select a move destination |
| `Reorder…` | `arrow.up.arrow.down` | — | Reorder sibling items |
| Separator | — | — | — |
| `Delete` | `trash` | — | Delete the item |

#### Scenario: Use an editing mode
- **WHEN** the list is in selection or reordering mode
- **THEN** the application does not present an item context menu
### Requirement: iOS document toolbar
The iOS and iPadOS applications SHALL present document controls across the top navigation bar and bottom toolbar according to the current interaction mode.

#### Scenario: Present the toolbar in standard mode
- **WHEN** the document is in standard interaction mode
- **THEN** the application displays the following controls:

| Placement | Control | Title | Icon | State | Action |
| --- | --- | --- | --- | --- | --- |
| Top navigation bar | More | — | `ellipsis` | Enabled | Present the More menu |
| Bottom toolbar | Undo/Redo group | — | System-provided | Enabled when available | Undo or redo a document change |
| Bottom toolbar | New item | — | `plus` | Enabled | Create an item |

#### Scenario: Present the More menu
- **WHEN** the user presents the More menu from the toolbar
- **THEN** the menu displays the following entries in order:

| Entry | Icon | Action |
| --- | --- | --- |
| `Select` | `checkmark.circle` | Enter selection mode |
| `Reorder` | `line.3.horizontal` | Enter reordering mode |
| Separator | — | — |
| `Expand All` | — | Expand all branches |
| `Collapse All` | — | Collapse all branches |
| Separator | — | — |
| `Settings…` | `slider.horizontal.2.square` | Present settings |

#### Scenario: Present selection mode without a selection
- **WHEN** the document is in selection mode and no items are selected
- **THEN** the application displays the following controls:

| Placement | Control | Title | Icon | State | Action |
| --- | --- | --- | --- | --- | --- |
| Top navigation bar | Done | `Done` | — | Enabled | Leave selection mode |
| Bottom toolbar | Select all | `Select All` | — | Enabled | Select all items |
| Bottom toolbar | Selection status | `Select Items` | — | Informational | — |
| Bottom toolbar | Selection actions | — | `ellipsis` | Disabled | Present selection actions |

#### Scenario: Present selection mode with a selection
- **WHEN** the document is in selection mode and one or more items are selected
- **THEN** the application displays the following controls:

| Placement | Control | Title | Icon | State | Action |
| --- | --- | --- | --- | --- | --- |
| Top navigation bar | Done | `Done` | — | Enabled | Leave selection mode |
| Bottom toolbar | Select all | `Select All` | — | Enabled | Select all items |
| Bottom toolbar | Selection status | `<count> Item Selected` or `<count> Items Selected` | — | Informational | — |
| Bottom toolbar | Selection actions | — | `ellipsis` | Enabled | Present selection actions |

#### Scenario: Present selection actions
- **WHEN** the user presents selection actions for one or more selected items
- **THEN** the menu displays the following entries in order:

| Entry | Icon | Action |
| --- | --- | --- |
| `Cut` | `scissors` | Cut selected items |
| `Copy` | `doc.on.doc` | Copy selected items |
| Separator | — | — |
| `Icon…` | `photo` | Select an icon |
| `Color…` | `paintpalette` | Select a color |
| Separator | — | — |
| `Move to…` | `arrow.left.arrow.right` | Select a move destination |
| Separator | — | — |
| `Strikethrough` | — | Toggle strikethrough |
| `Hide subitems` | — | Toggle subitem visibility |
| Separator | — | — |
| `Delete` | `trash` | Delete selected items |

#### Scenario: Present the toolbar in reordering mode
- **WHEN** the document is in reordering mode
- **THEN** the top navigation bar displays an enabled `Done` button that leaves reordering mode, and the bottom toolbar displays no actionable controls

### Requirement: macOS list document toolbar
The macOS application SHALL present a document toolbar containing an item-creation control and no document-view selection controls.

#### Scenario: Present the document toolbar
- **WHEN** a document window is open
- **THEN** the application displays an enabled `New Item` control with the `plus` icon
- **AND THEN** it does not display a view switcher or a new-column control
