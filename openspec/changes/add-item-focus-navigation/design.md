## Context

The macOS content interface already presents a subtree by giving `ContentInteractor` an optional root and deriving a relative snapshot. The same assembly is reused by focused child windows and descendant outlines inside the columns interface. Focus navigation is therefore a standard behavior of each macOS content unit rather than an opt-in assembly capability.

`DocumentContent` already exposes physical parent lookup, which is sufficient to seed an ordered navigation route without changing the hierarchy model. The current storage-observation closure in `ContentInteractor` captures the initializer's root argument; it must instead use the current root state so an in-place focus change receives correct later updates.

See proposal.md and the application-interface delta specification for the required user behavior.

## Goals / Non-Goals

**Goals:**

- Reuse the existing root-relative snapshot and destination semantics for focused content.
- Keep focus state isolated to its macOS content presentation and recover at the deepest existing route scope when a focused root is deleted.
- Render and operate an AppKit path control from the physical hierarchy path.
- Recover every content presentation at the deepest existing route component when its focused root is deleted.

**Non-Goals:**

- Persisting focus state, changing the `.nlist` format, or adding migrations.
- Changing item hierarchy, mirror semantics, undo history, copy/paste, or drag-and-drop rules.
- Adding in-place focus navigation to iOS or iPadOS.
- Removing the macOS columns interface.
- Adding UI automation beyond context-menu coverage.

## Decisions

### Make in-place focus a standard macOS content capability

`ContentUnitAssembly` will build its view, presenter, and interactor with focus navigation enabled by default, without a capability flag. Focused child windows and `ColumnUnitAssembly` reuse the same content behavior.

This removes configuration that is only needed to accommodate the retiring columns interface while keeping the shared presentation code straightforward. All content presentations recover a deleted focused root at the deepest existing path component.

Alternative considered: retain an explicit assembly capability. It adds configuration plumbing without benefit once the columns interface is removed.

### Keep navigation state in the macOS content presentation layer

The active focus is a window-local navigation route owned by the content interactor/presenter pair. Each route step identifies the scope shown at that point and its path component. A primary content window seeds its route from the selected item's physical ancestors. A content window opened for an item stores that item as its initial root and calculates later route components relative to it. Selecting `Focus` appends or restores a scope; selecting a path component truncates the route to that component. The current scope requests a fresh root-relative snapshot, updates the title/path, clears stale selection, and expands the visible hierarchy using existing list behavior.

The path model contains a synthetic document-root component followed by the route's physical item components. Mirrors do not become focused roots in the first version, so a route never contains a virtual mirror step. The `Focus` command is disabled when its first selected item is a mirror.

Alternative considered: add a persisted `Item` or `DocumentContent` view property. Focus is navigation state, not document content; persistence would require a format decision, migration, and cross-window reconciliation without user benefit.

### Present the path control in the list view footer

Each macOS content view will place a native path control below its scroll view. The control is hidden while its route contains only one component: the document root in a primary window or the initial root in a child content window. When a route adds a focused component, the control displays the route's item components. Its action delegates a selected component identifier to the presenter, which either selects that root or restores the document root and hides the control.

The footer remains present when the focused item has no visible descendants so the empty state does not trap navigation.

Alternative considered: use a toolbar breadcrumb. The requested lower-window placement avoids consuming document-toolbar space and keeps the control adjacent to the scoped outline.

### Handle document mutations against the current root

Storage observation will evaluate the current route, not the root passed at construction. After a mutation, it validates each route component and its physical parent link, then truncates the route at the longest valid prefix and renders that deepest remaining scope. It renders the normal document outline only when a primary window's route has no remaining component. A child content window closes when its initial root no longer exists.

Existing root-relative insertion, move, copy, paste, and drag-and-drop operations continue to calculate destinations relative to the active root. This preserves the expected behavior of operating inside a focused subtree. Focus navigation itself changes no document data and creates no undo operation.

### Use existing analytics event types

Selecting `Focus` reports the existing `menu_item_click` event with stable id `focus`. Selecting a path component reports the existing `button_click` event with stable id `focus-path-component`. No new event name or analytics schema is introduced.

## Risks / Trade-offs

- [A focused route component is deleted, moved, or invalidated by another window] → Re-evaluate the route on every storage observation and truncate it to its deepest component with a valid physical parent chain; close a child content window when its initial root is deleted.
- [A user attempts to focus a mirror] → Disable the `Focus` command for a mirror selection.
- [Footer layout overlaps the outline or placeholder] → Constrain the scroll view above the path control and verify both populated and empty states.
- [Focus navigation is temporarily available in columns] → The columns interface is scheduled for removal; shared content behavior avoids retaining transitional capability plumbing.

## Migration Plan

No data migration or deployment sequencing is required. The feature stores no document data. Rollback consists of removing the macOS presentation behavior; all existing `.nlist` documents remain unchanged and readable.
