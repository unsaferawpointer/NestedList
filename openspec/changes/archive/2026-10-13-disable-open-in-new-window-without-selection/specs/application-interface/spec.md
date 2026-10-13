## MODIFIED Requirements

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
