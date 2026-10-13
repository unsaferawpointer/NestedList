## Context

The existing macOS menu update removes `Open in New Window` during menu validation when the content selection is empty. `ContentViewController` already conforms to `NSMenuItemValidation`, which can set the command state without changing its identity, placement, or action routing.

## Goals / Non-Goals

**Goals:**

- Keep the command visible and disabled with an empty effective selection.
- Preserve the existing enabled-path behavior, including opening only the first selected item and generic menu-click analytics.

**Non-Goals:**

- Change the iOS or iPadOS menus.
- Change focused-window routing, menu order, document persistence, or multiwindow behavior.

## Decisions

### Reuse standard AppKit menu validation

The content presenter will continue to expose whether a menu identifier is enabled for the current selection. `ContentViewController` will supply that result through its existing `NSMenuItemValidation` conformance when AppKit validates context-menu items. The temporary `ListAdapter` menu-update callback and the view-controller helper that consumes it will be removed.

This reuses the standard AppKit validation route and prevents an empty selection from reaching the open-window action through the UI. Removing the action entirely was rejected because it reduces discoverability and changes the menu layout.

### Retain action routing and analytics

The `open-in-new-window` handler and generic `menu_item_click` reporting remain unchanged. Disabled AppKit menu items cannot be activated, so no separate disabled-action guard or analytics event is necessary.

## Risks / Trade-offs

- [Menu state can become stale between presentations] → AppKit re-evaluates enabled state whenever it validates the context menu.
- [A disabled item is visually less prominent than an omitted item] → This is intentional: it communicates that selection is required while preserving discoverability.

## Migration Plan

No migration is required. The change affects only macOS presentation state and can be reverted by restoring the prior visibility rule.
