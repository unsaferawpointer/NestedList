## Context

See [proposal.md](proposal.md) for motivation and [the column-context-menu spec](specs/column-context-menu/spec.md) for observable behavior. The macOS Column unit already builds a header menu and renders the column root using the shared item presentation model. The Content unit already provides the required picker routes and item-property operations.

## Goals / Non-Goals

**Goals:**

- Extend the Column unit so header-menu actions mutate its configured root item.
- Reuse the existing icon picker, color picker, item presentation, and document mutation patterns.
- Keep the strikethrough semantics identical to a normal item, including propagation to descendants and the completion-behaviour setting.

**Non-Goals:**

- Change menus in iOS or iPadOS.
- Add new document properties or migrate existing documents.
- Add clipboard, note, or subitem-visibility commands to the column header.

## Decisions

### Represent the actions with column-specific menu identifiers

Add column-menu identifiers for strikethrough, icon selection, color selection, and the existing appearance section header. This keeps the header's menu limited to actions valid for a column while allowing the shared menu builder to supply the same labels and symbols as the Content unit. Reusing `ContentMenuIdentifier` was rejected because its menu contains selection-oriented and clipboard actions that do not apply to a column header.

### Route pickers through the existing column router

The Column presenter already owns a `ContentRouterProtocol`, which exposes both pickers. It will use those routes and update the configured root item through its interactor. This avoids duplicating SwiftUI picker presentation and preserves the existing cancellation behavior.

### Mutate root-item properties through the shared interactor

The Column interactor will expose focused operations for setting icon and color and for toggling strikethrough for its root. Icon and color updates affect only that root item. Strikethrough uses the shared item operation so its descendant propagation and optional move-to-end behavior remain consistent with normal list items.

### Add column menu analytics

The Column presenter will depend on the established concrete analytics service and emit `menu_item_click` with the corresponding menu identifier for each new selectable action. This follows the project analytics taxonomy without adding custom event names.

## Risks / Trade-offs

- [Marking a column as complete can move it among sibling columns when the completion setting enables it] → Preserve the normal-item behavior explicitly and cover it with focused interactor tests.
- [Header menu state can become stale after an external document update] → Derive the checkmark from the latest root item when the menu validates, while the existing storage observation refreshes the header.
- [The Column unit currently has limited test coverage] → Add presenter and interactor tests for menu routing, mutations, and state validation.

## Migration Plan

No migration is required. The change uses existing persisted properties that remain compatible with current `.nlist` documents. Rolling back only removes access to the new header actions; stored item properties remain valid.
