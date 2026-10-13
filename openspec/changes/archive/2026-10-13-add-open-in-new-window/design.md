## Context

The macOS content outline already exposes its effective selection to the presenter and already opens a focused child window for a given item through the content router. That existing window shares the document storage, is associated with the owning document, and closes when its root item is removed. See `proposal.md` for the user motivation.

## Goals / Non-Goals

**Goals:**

- Expose the existing focused-window behavior through a macOS item context-menu command.
- Preserve context-menu selection semantics: a right-clicked unselected row becomes the effective selection, while a context menu without an effective selection omits the command.
- Keep the change platform-specific and compatible with the existing analytics schema.

**Non-Goals:**

- Change the disclosure control or the focused-window lifecycle.
- Add the command to iOS, iPadOS, the toolbar, or the main menu.
- Open a window for every selected item.
- Change the document model, persisted state, undo stack, or drag-and-drop behavior.

## Decisions

### Add a macOS-only content-menu identifier

The shared content-menu identifier will declare the command only for macOS, with the stable raw value `open-in-new-window`. This keeps iOS and iPadOS menu builders and their exhaustive handling unchanged while allowing the macOS menu infrastructure to use its existing identifier flow.

Alternative considered: add an identifier available on every platform. Rejected because the command is intentionally out of scope outside the macOS target and would create unnecessary platform handling.

### Reuse the existing focused-window router operation

The macOS presenter will route the first effective selected identifier to the existing focused-window operation. That operation already assembles the focused content, creates and positions a child window, registers it with the parent document, and keeps its title synchronized with the focused item.

Alternative considered: create a separate window-building path for the context-menu action. Rejected because it risks diverging document ownership, close behavior, and live content updates from the existing disclosure action.

### Use visual selection order and a synchronous command label

The presenter will use the first effective selected item, whose order follows the outline rows. The menu label will be `Open in New Window`, without an ellipsis, because the command completes immediately without requesting further input. The command will sit after the creation commands and before item-editing commands, and will be omitted when there is no effective selection.

Alternative considered: use `Open in New Window…`. Rejected because the ellipsis would imply a subsequent choice or input that the action does not require.

### Reuse menu-click analytics

The command will use the existing `menu_item_click` reporting path with `id: "open-in-new-window"` and the existing context-menu source metadata. No custom analytics event is introduced.

## Risks / Trade-offs

- [Multiple selections can be interpreted as multiple window requests] → The specification and presenter select only the topmost effective selected item; a unit test verifies the routed identifier.
- [A new menu entry can regress ordering or visibility] → Add macOS UI coverage for the visible title with a selection and the command's absence without a selection, plus presenter tests for routing and analytics.
- [Focused-window behavior could diverge between entry points] → Both the disclosure action and context-menu command use the same router operation.

## Migration Plan

No migration is required. The change adds a macOS-only command and localized strings without modifying persisted document content or the `.nlist` format. Rollback consists of removing the command entry and its identifier; existing documents and child-window behavior remain unaffected.
