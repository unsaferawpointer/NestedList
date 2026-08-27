# application-interface Specification

## Purpose

Defines the user-visible presentation of the NestedList application interface.

## Requirements

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
