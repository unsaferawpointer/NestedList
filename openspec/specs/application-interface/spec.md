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
| macOS | Document window chrome, window controls, document title handling, and standard document commands | List and columns content, focused item windows, document toolbar, context menus, and placeholders |

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

### Requirement: macOS primary windows
The macOS application SHALL provide the following primary windows. Item details and appearance pickers SHALL be presented as sheets attached to a document window rather than as primary windows.

#### Scenario: Present a document window with list view selected
- **WHEN** a document window uses the list view
- **THEN** the application presents a resizable document window with the document toolbar and a hierarchical outline in list view

#### Scenario: Present a document window with columns view selected
- **WHEN** a document window uses the columns view
- **THEN** the application presents a resizable document window with the document toolbar, horizontal scrolling, and adjacent hierarchy columns containing item headers and descendant outlines

#### Scenario: Open a focused item window
- **WHEN** the user opens an item in a focused window
- **THEN** the application presents a child window associated with the same document and titles it with the focused item text

#### Scenario: Present onboarding
- **WHEN** onboarding is shown on macOS
- **THEN** the application presents a resizable modal window with a hidden title, transparent title bar, feature content, and footer actions

### Requirement: macOS document placeholders
The macOS application SHALL present a placeholder when the active document view contains no visible content.

#### Scenario: Present an empty list
- **WHEN** the list view is selected and the document contains no visible items
- **THEN** the window displays the following placeholder:

| Icon | Title | Subtitle |
| --- | --- | --- |
| `plus.square.on.square` | `No items yet` | `To add a new item, click the «plus» button or use the keyboard shortcut ⌘T` |

#### Scenario: Present an empty focused item window
- **WHEN** a focused item window contains no visible descendants
- **THEN** the window displays the following placeholder:

| Icon | Title | Subtitle |
| --- | --- | --- |
| `plus.square.on.square` | `No items yet` | `To add a new item, click the «plus» button or use the keyboard shortcut ⌘T` |

#### Scenario: Present empty columns
- **WHEN** the columns view is selected and the document contains no columns
- **THEN** the window displays the following placeholder:

| Icon | Title | Subtitle |
| --- | --- | --- |
| `rectangle.split.3x1` | `No columns yet` | `To add a new column, click the «plus» button or use the keyboard shortcut ⌘T` |

### Requirement: macOS item context menu
The macOS application SHALL present an item context menu based on the current selection.

#### Scenario: Present the context menu without a selection
- **WHEN** no items are selected
- **THEN** the context menu displays the following entries:

| Entry | Icon | Shortcut | Action |
| --- | --- | --- | --- |
| `New Item` | `plus` | `⌘T` | Create an item |

#### Scenario: Present the context menu with a selection
- **WHEN** one or more items are selected
- **THEN** the context menu displays the following entries in order:

| Entry | Icon | Shortcut | Action |
| --- | --- | --- | --- |
| `New Item` | `plus` | `⌘T` | Create an item |
| Separator | — | — | — |
| `Edit…` | `square.and.pencil` | — | Edit item details |
| Separator | — | — | — |
| `Strikethrough` | — | `⌘↩` | Toggle strikethrough |
| `Hide subitems` | — | — | Toggle subitem visibility |
| Separator | — | — | — |
| `Note` | `note.text` | — | Toggle note visibility |
| Separator | — | — | — |
| `Appearance` | — | — | — |
| `Icon…` | `photo` | — | Select an icon |
| `Color…` | `paintpalette` | — | Select a color |
| Separator | — | — | — |
| `Delete` | `trash` | `⌘⌫` | Delete selected items |

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

### Requirement: macOS document toolbar
The macOS application SHALL present a document toolbar containing a view switcher and a creation button appropriate to the selected document view.

#### Scenario: Present the toolbar in list view
- **WHEN** the document uses the list view
- **THEN** the application displays the following controls in order:

| Control | Title | Icon | State | Action |
| --- | --- | --- | --- | --- |
| List view segment | — | `list.bullet` | Selected | Display the document as a list |
| Columns view segment | — | `rectangle.split.3x1` | Unselected | Display the document as columns |
| New item | `New Item` | `plus` | Enabled | Create an item |

#### Scenario: Present the toolbar in columns view
- **WHEN** the document uses the columns view
- **THEN** the application displays the following controls in order:

| Control | Title | Icon | State | Action |
| --- | --- | --- | --- | --- |
| List view segment | — | `list.bullet` | Unselected | Display the document as a list |
| Columns view segment | — | `rectangle.split.3x1` | Selected | Display the document as columns |
| New column | `New Column` | `plus` | Enabled | Create a column |
