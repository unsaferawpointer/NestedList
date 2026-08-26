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
