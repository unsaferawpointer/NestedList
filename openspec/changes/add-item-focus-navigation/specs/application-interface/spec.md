## ADDED Requirements

### Requirement: macOS in-place focused outline navigation
In a macOS content outline, the system SHALL allow the user to focus the outline on an item without opening another window. The focused outline SHALL show the focused item's visible descendants as its root-level rows and SHALL present a path control at the bottom of the content view.

The path control SHALL be hidden while the navigation route contains only one component: the document-root scope in a primary window or the initial root in a child content window. When the route contains a focused component beyond its initial root, the control SHALL contain the user's retained navigation route. The initial route to an item SHALL use that item's physical ancestor chain. A mirror SHALL NOT become a focused root. Selecting a route component SHALL restore the scope represented by that component; selecting the document-root component SHALL restore the complete document outline and hide the path control.

A content window opened for an item SHALL keep that item as its initial root. Its path route SHALL begin at that initial root and SHALL calculate later focused scopes relative to it.

Focus state SHALL be local to its content presentation, SHALL NOT be serialized into the `.nlist` document, and SHALL NOT affect other content presentations for the same document.

#### Scenario: Focus a selected item in the current window
- **WHEN** the user selects `Focus` for an item in a macOS content outline
- **THEN** that item becomes the focused root in the same window
- **AND THEN** the outline displays the item's descendants as root-level rows
- **AND THEN** the bottom path control ends with the focused item

#### Scenario: Focus an item in a child content window
- **WHEN** a content window opens with an item as its root
- **AND WHEN** the user focuses a visible descendant
- **THEN** the path control starts with the opening item's component
- **AND THEN** it contains the physical descendant path to the focused item

#### Scenario: Navigate to an ancestor from the path control
- **WHEN** a focused item's path control contains one or more earlier route components
- **AND WHEN** the user selects an earlier component
- **THEN** the navigation route is restored through the selected component
- **AND THEN** the outline displays the scope represented by that component

#### Scenario: Return to the document root
- **WHEN** the user selects the document-root component in the path control
- **THEN** the window displays the complete document outline
- **AND THEN** the path control is hidden

#### Scenario: Focus an item without visible descendants
- **WHEN** the user focuses an item that has no visible descendants
- **THEN** the window displays the existing empty-list placeholder
- **AND THEN** the path control remains available to navigate to an ancestor or the document root

#### Scenario: Do not focus a mirror
- **WHEN** the first selected item in a macOS content outline is a mirror
- **THEN** the `Focus` command is disabled
- **AND THEN** the mirror does not become a focused root

#### Scenario: Delete the focused item
- **WHEN** a focused route component other than a child content window's initial root is removed from the document
- **THEN** the content presentation remains open
- **AND THEN** it restores the deepest remaining component in the previous navigation route
- **AND THEN** it returns to the complete document outline with the document-root path component only when no route component remains

#### Scenario: Delete a child content window's initial root
- **WHEN** the initial root of a child content window is removed from the document
- **THEN** the child content window closes

#### Scenario: Move the focused item
- **WHEN** the focused item is moved so it is no longer a child of its preceding route component
- **THEN** the content presentation restores the deepest preceding route component whose physical parent chain still exists

#### Scenario: Keep focus window-local and non-persistent
- **WHEN** the user focuses an item in one document window
- **THEN** other windows for the same document retain their own outline scope
- **AND THEN** saving and reopening the document displays its normal document-root outline

## MODIFIED Requirements

### Requirement: macOS item context menu
The macOS application SHALL present an item context menu based on the current selection. The menu SHALL always include the `Open in New Window` command. The command SHALL be disabled when no item is selected and enabled when one or more items are selected; when enabled, it SHALL open a focused child window for the first selected item in the outline's visual order.

In a macOS content outline, the menu SHALL also include the `Focus` command. The command SHALL be disabled when no item is selected or when the first selected item is a mirror; otherwise it SHALL focus the first selected item in the outline's visual order in the current content presentation.

#### Scenario: Present the context menu without a selection
- **WHEN** no items are selected in a macOS content outline
- **THEN** the context menu displays the following entries:

| Entry | Icon | Shortcut | State | Action |
| --- | --- | --- | --- | --- |
| `New Item` | `plus` | `⌘T` | Enabled | Create an item |
| `New Mirror…` | `arrow.triangle.branch` | — | Enabled | Open mirror source selection |
| Separator | — | — | — | — |
| `Focus` | `viewfinder` | — | Disabled | — |
| `Open in New Window` | `macwindow.on.rectangle` | — | Disabled | — |

#### Scenario: Present the context menu with a selection
- **WHEN** one or more items are selected in a macOS content outline
- **AND WHEN** the selected item nearest the top of the outline is not a mirror
- **THEN** the context menu displays the following entries in order:

| Entry | Icon | Shortcut | State | Action |
| --- | --- | --- | --- | --- |
| `New Item` | `plus` | `⌘T` | Enabled | Create an item |
| `New Mirror…` | `arrow.triangle.branch` | — | Enabled | Open mirror source selection |
| Separator | — | — | — | — |
| `Focus` | `viewfinder` | — | Enabled | Focus the first selected item in the current window |
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

#### Scenario: Focus the first item from a multiple selection
- **WHEN** the user selects `Focus` while multiple items are selected in a macOS content outline
- **THEN** the application focuses the selected item nearest the top of the outline
- **AND THEN** it does not focus the remaining selected items
