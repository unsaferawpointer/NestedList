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
| Focused item outline | Focused state of the current document screen | Hierarchical outline of the focused item's visible descendants with the document toolbar and bottom navigation path |
| Onboarding | Modal screen | Paged feature content with an icon, title, description, and footer actions |

#### Scenario: Navigate to a focused item outline
- **WHEN** the user opens an item as a focused outline
- **THEN** the current document screen displays the focused item outline without pushing another screen
- **AND THEN** its bottom path control provides navigation to physical ancestors and the document root

#### Scenario: Focus hidden subitems on the current screen
- **WHEN** the user activates the hidden-subitems disclosure of a non-mirror item on iOS or iPadOS
- **THEN** the current screen focuses on that item and shows its visible descendants
- **AND THEN** the bottom path control preserves access to earlier scopes without adding a screen to the navigation stack

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
In a macOS content outline, the system SHALL display a trailing disclosure arrow if and only if the item's subitems are hidden and the item is not a mirror. A mirror SHALL NOT display the arrow, even when its referenced original hides its subitems. Selecting that arrow SHALL focus the current content presentation on the item rather than opening a child window. The focused presentation SHALL show the item's visible descendants as root-level rows and retain the document and item-navigation behavior of the current window. Opening a child window SHALL remain available only through the explicit `Open in New Window` command.

#### Scenario: Hide the disclosure arrow for a mirror
- **WHEN** a mirror is displayed in a macOS content outline
- **THEN** the trailing disclosure arrow is hidden
- **AND THEN** the arrow remains hidden even when the referenced original hides its subitems

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

#### Scenario: Select a mirror in the macOS context menu
- **WHEN** the first selected item in the outline's visual order is a mirror
- **THEN** `Focus` is disabled
- **AND THEN** `Open in New Window` retains its existing selection-based availability

### Requirement: iOS item context menu
The iOS and iPadOS applications SHALL present a context menu for an outline item when the list is not in an editing mode. The menu SHALL include `Focus` with the `viewfinder` icon. The command SHALL focus that context-menu item in the current screen when it is not a mirror and SHALL be disabled for a mirror.

#### Scenario: Present the context menu for an item
- **WHEN** the user presents the context menu for an item
- **THEN** the context menu displays the following entries in order:

| Entry | Icon | Shortcut | Action |
| --- | --- | --- | --- |
| `Cut` | `scissors` | — | Cut the item |
| `Copy` | `doc.on.doc` | — | Copy the item |
| `Paste` | `doc.on.clipboard` | — | Paste content |
| Separator | — | — | — |
| `Focus` | `viewfinder` | — | Focus the context-menu item in the current screen; disabled for mirrors |
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

#### Scenario: Use Focus for the context-menu target
- **WHEN** the user invokes `Focus` for a non-mirror outline item on iOS or iPadOS
- **THEN** that context-menu item becomes the current screen's focused root
- **AND THEN** the application does not push another screen

#### Scenario: Present Focus for a mirror
- **WHEN** the user presents a mirror's context menu on iOS or iPadOS
- **THEN** the menu includes `Focus` in the same position with the command disabled

### Requirement: iOS document toolbar
The iOS and iPadOS applications SHALL present document controls across the top navigation bar and bottom toolbar according to the current interaction mode. In selection edit mode, the selection-actions menu SHALL include Focus for the first selected item in outline order, disabled if that item is a mirror; successful Focus SHALL restore standard interaction mode on the same screen.

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
| `Focus` | `viewfinder` | Focus the first selected item in outline order; disabled if it is a mirror |
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

### Requirement: In-place focused outline navigation
On iOS, iPadOS, and macOS, the system SHALL allow the user to focus an outline on an item within the current content presentation. Focusing SHALL show the item's visible descendants as root-level rows without opening another screen or window, changing document data, or adding an undo operation. A mirror SHALL NOT become a focused root.

A bottom path control SHALL show the retained physical route from the presentation's initial scope through the focused item. For a document-root presentation, its first component SHALL represent the document. For a presentation opened with an item as its initial root, the route SHALL start at that item and later focus targets SHALL remain within that item's physical subtree. The control SHALL be hidden when the route contains only its initial component.

Selecting an earlier path component SHALL restore that component's scope and truncate the route after it. Selecting the document component SHALL restore the complete document outline and hide the path control. In a presentation with an item as its initial root, selecting that first component SHALL restore its subtree and hide the control.

Focus state SHALL remain local to each content presentation, SHALL NOT affect other presentations of the same document, and SHALL NOT be serialized in the `.nlist` document. Existing documents SHALL remain readable without migration.

#### Scenario: Focus a selected item in the current macOS window
- **WHEN** the user selects `Focus` for a non-mirror item in a macOS content outline
- **THEN** that item becomes the focused root in the same window
- **AND THEN** no additional window opens
- **AND THEN** the outline displays its visible descendants as root-level rows and the bottom path control ends with that item

#### Scenario: Focus a context-menu item on the current iOS or iPadOS screen
- **WHEN** the user selects `Focus` from a non-mirror item's context menu on iOS or iPadOS
- **THEN** that item becomes the focused root on the current screen
- **AND THEN** the navigation stack does not gain a screen
- **AND THEN** the outline displays its visible descendants as root-level rows and the bottom path control ends with that item

#### Scenario: Focus an item within an initially scoped presentation
- **WHEN** a content presentation starts with an item as its initial root
- **AND WHEN** the user focuses a visible descendant
- **THEN** the path control starts with the initial root and contains the physical descendant path to the focused item
- **AND THEN** targets outside the initial root's subtree do not change the focus

#### Scenario: Navigate to an ancestor from the path control
- **WHEN** the user selects an earlier component of the focused outline's path control
- **THEN** the route is truncated through the selected component
- **AND THEN** the same content presentation displays that component's scope

#### Scenario: Return to the document root
- **WHEN** the user selects the document component in the path control
- **THEN** the current screen or window displays the complete document outline
- **AND THEN** the path control is hidden

#### Scenario: Return to an item presentation's initial root
- **WHEN** the user selects the first path component in a presentation initially scoped to an item
- **THEN** the same presentation displays that initial item's subtree
- **AND THEN** the path control is hidden

#### Scenario: Focus an item without visible descendants
- **WHEN** the user focuses an item that has no visible descendants
- **THEN** the presentation displays its platform's existing empty-outline state
- **AND THEN** the path control remains visible and usable to return to an earlier scope

#### Scenario: Do not focus a mirror
- **WHEN** the context-menu focus target is a mirror
- **THEN** the `Focus` command is disabled
- **AND THEN** invoking the focus action does not make that mirror a focused root

#### Scenario: Create or paste content inside the focused scope
- **WHEN** the user creates an item or pastes content at the outline root while an item is focused
- **THEN** the content is inserted under the focused item
- **AND THEN** subsequent document updates continue to display the active focused subtree

#### Scenario: Drop content at the focused outline root
- **WHEN** a supported drag-and-drop operation targets the root of a focused outline
- **THEN** its destination is relative to the focused item
- **AND THEN** the document's existing move, copy, and insertion rules continue to apply

#### Scenario: Delete the focused item
- **WHEN** a focused route component beyond the initial root is removed from the document
- **THEN** the content presentation remains open and restores the deepest preceding component whose physical parent chain still exists
- **AND THEN** it returns to the document outline only when the document component is the deepest remaining scope

#### Scenario: Delete a child content window's initial root on macOS
- **WHEN** the initial root of a macOS child content window is removed from the document
- **THEN** that child window closes

#### Scenario: Delete an initially scoped item's root on iOS or iPadOS
- **WHEN** an iOS or iPadOS content presentation's initial item root is removed from the document
- **THEN** the current presentation recovers to the document-root outline
- **AND THEN** its path control is hidden

#### Scenario: Move the focused item
- **WHEN** the focused item is moved so it is no longer a child of its preceding route component
- **THEN** the presentation restores the deepest preceding component whose physical parent chain still exists

#### Scenario: Keep focus local and non-persistent
- **WHEN** the user focuses an item in one presentation of a document
- **THEN** other presentations retain their own outline scope
- **AND THEN** saving and reopening the document displays its normal document-root outline

### Requirement: iOS focus selection in edit mode
On iOS and iPadOS, the selection-actions menu in selection edit mode SHALL include `Focus` with the `viewfinder` icon. The focus target SHALL be the selected item nearest the top of the current visible outline, independent of the order in which the user selected items. The action SHALL be disabled when no item is selected or that first selected item is a mirror; it SHALL NOT substitute a later non-mirror selection.

Invoking an enabled action SHALL leave selection edit mode, focus that single item on the current screen, clear the old selection, display its visible descendants, and update the bottom path control. The navigation stack SHALL remain unchanged. Item context menus SHALL remain unavailable during selection or reordering mode; edit-mode Focus SHALL be available through the selection-actions menu.

#### Scenario: Focus one selected item in edit mode
- **WHEN** one non-mirror item is selected in selection edit mode and the user chooses `Focus` from the selection-actions menu
- **THEN** the application exits selection edit mode and focuses that item on the same screen
- **AND THEN** its descendants and navigation path replace the previous outline scope

#### Scenario: Focus the first of multiple selected items
- **WHEN** multiple items are selected in selection edit mode and the user chooses `Focus`
- **THEN** the selected item nearest the top of the outline becomes the focused root
- **AND THEN** no other selected item is focused
- **AND THEN** this result does not depend on the order of selection taps

#### Scenario: Leave selection mode after focusing
- **WHEN** edit-mode Focus succeeds
- **THEN** the previous selection is cleared and standard document controls are restored
- **AND THEN** no additional screen is pushed onto the navigation stack

#### Scenario: No items are selected in edit mode
- **WHEN** selection edit mode has no selected items
- **THEN** the selection-actions control is disabled and Focus cannot be invoked
- **AND THEN** invoking the action without a selection does not change the outline scope or leave edit mode

#### Scenario: The first selected item is a mirror
- **WHEN** the selected item nearest the top of the outline is a mirror
- **THEN** Focus is disabled even if another selected item is not a mirror
- **AND THEN** invoking the action does not change the outline scope or leave edit mode

#### Scenario: A later selected item is a mirror
- **WHEN** the first selected item is not a mirror and a later selected item is a mirror
- **THEN** Focus is enabled and targets only the first selected item

### Requirement: Focus path control presentation
The application SHALL keep the bottom path control readable and operable while the outline is scrolled or empty. The outline's final rows and scroll indicator SHALL remain reachable above the control. On iOS and iPadOS, a long path SHALL support horizontal scrolling and keep the current component visible; the component height SHALL adapt to the user's text-size setting.

#### Scenario: Show the path on macOS
- **WHEN** a macOS outline is focused beyond its initial scope
- **THEN** the content view shows its path control at the bottom of the outline
- **AND THEN** the outline and empty-state presentation preserve access to the control

#### Scenario: Scroll an outline beneath the iOS or iPadOS path
- **WHEN** a focused iOS or iPadOS outline is scrolled
- **THEN** its path remains positioned at the bottom of the content safe area
- **AND THEN** the outline reserves sufficient bottom scrolling space for its final row and scroll indicator
- **AND THEN** on iOS and iPadOS 26 or later, the outline's bottom scroll-edge effect accounts for the path's visible components
- **AND THEN** on earlier supported versions, the path remains readable against an opaque background

#### Scenario: Navigate through a long path with larger text
- **WHEN** the path does not fit the available width or the preferred text size increases on iOS or iPadOS
- **THEN** the user can scroll the path horizontally and select earlier components
- **AND THEN** the current component remains visible and path text is not clipped vertically

### Requirement: Focus navigation analytics
On both platforms, selecting the `Focus` context-menu command SHALL report `menu_item_click` in the `content` area with `id` `focus` and `source` `context-menu`. Selecting Focus from the iOS or iPadOS edit-mode selection-actions menu SHALL report the same event name and identifier with `source` `toolbar-button-menu`; it SHALL NOT be reported as a toolbar `button_click`. Selecting a path component SHALL report `button_click` in the `content` area with `id` `focus-path-component` and `source` `path-control`. These events SHALL NOT include item identifiers, item text, document names, or hierarchy paths.

#### Scenario: Report focus selection
- **WHEN** the user selects an enabled `Focus` context-menu command on iOS, iPadOS, or macOS
- **THEN** the application reports the existing menu-item event with the stable focus command identifier
- **AND THEN** its payload contains no user-authored content or item identifiers

#### Scenario: Report edit-mode focus selection
- **WHEN** the user selects an enabled Focus action in the iOS or iPadOS selection-actions menu
- **THEN** the application reports `menu_item_click` in the `content` area with `id` `focus` and `source` `toolbar-button-menu`
- **AND THEN** the event includes neither selected item identifiers nor the selection's content

#### Scenario: Report path navigation
- **WHEN** the user selects a path component on iOS, iPadOS, or macOS
- **THEN** the application reports the existing button event with the stable path-control identifier
- **AND THEN** its payload does not identify the selected component or its content
