## Context

The macOS content cell exposes a trailing disclosure action only when an item's subitems are hidden. Its delegate action currently follows the separate-window flow, while the current content presenter already has a window-local focus-navigation flow from the `add-item-focus-navigation` change. This change redirects one interaction to that existing focus capability without changing the item hierarchy or its persisted options.

## Goals / Non-Goals

**Goals:**

- Route trailing-disclosure activation for hidden subitems to the current presenter's focus operation.
- Preserve one-window navigation state, including the path control and empty-list presentation.
- Report the control activation as the existing `button_click` analytics event with a stable action identifier and no document content.

**Non-Goals:**

- Changing the visibility semantics of `Hide subitems`.
- Removing or changing the explicit `Open in New Window` command.
- Changing iOS or iPadOS disclosure behavior.
- Persisting focus state or changing the document model.

## Decisions

### Reuse the current-window focus flow

The disclosure delegate will invoke the presenter's existing focus operation for the tapped item. This preserves the navigation resolver, path control, placeholder, and multiple-window isolation already established for the focus command.

Alternative: introduce a disclosure-specific navigation path. This is rejected because it would duplicate focus-state rules and could diverge from context-menu navigation.

### Keep window creation behind its explicit command

The disclosure action will not call the child-window creation flow. `Open in New Window` remains the sole command that requests a new focused content window.

Alternative: retain window creation after focus. This is rejected because it defeats in-place navigation and creates an unnecessary duplicate window.

### Report the action as a button click

The presenter will report the disclosure interaction through the established `button_click` event using a stable action identifier that describes focus. It will not include item identifiers or content.

Alternative: retain the subitems-show event. This is rejected because the action no longer reveals subitems in the current outline.

## Risks / Trade-offs

- [The focus-navigation implementation is still maintained in a separate active change] → Reuse its public presenter/interactor contract and apply this change after that change's focus flow is available.
- [A regression could silently open a child window] → Add presenter tests asserting focus invocation and absence of a window-opening invocation.
- [Analytics semantics could retain the previous event] → Assert the stable button-click identifier in the disclosure-action test.

## Migration Plan

No migration is required. The change affects only macOS in-memory presentation state and can be rolled back by restoring the previous disclosure action.
