## MODIFIED Requirements

### Requirement: macOS item context menu
The macOS application SHALL present an item context menu based on the current selection. When one or more items are selected, the menu SHALL include the `Open in New Window` command, which opens a focused child window for the first selected item in the outline's visual order.

#### Scenario: Present the context menu without a selection
- **WHEN** no items are selected
- **THEN** the context menu displays the following entries:

| Entry | Icon | Shortcut | Action |
| --- | --- | --- | --- |
| `New Item` | `plus` | `⌘T` | Create an item |
| `New Mirror…` | `arrow.triangle.branch` | — | Open mirror source selection |
- **AND THEN** the context menu does not display `Open in New Window`

#### Scenario: Present the context menu with a selection
- **WHEN** one or more items are selected
- **THEN** the context menu displays the following entries in order:

| Entry | Icon | Shortcut | Action |
| --- | --- | --- | --- |
| `New Item` | `plus` | `⌘T` | Create an item |
| `New Mirror…` | `arrow.triangle.branch` | — | Open mirror source selection |
| Separator | — | — | — |
| `Open in New Window` | `macwindow.on.rectangle` | — | Open the first selected item in a focused child window |
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

#### Scenario: Open the first item from a multiple selection
- **WHEN** the user selects `Open in New Window` while multiple items are selected
- **THEN** the application opens a focused child window for the selected item nearest the top of the outline
- **AND THEN** it does not open windows for the remaining selected items
