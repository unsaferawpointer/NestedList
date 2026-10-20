## Why

On macOS, the trailing disclosure arrow for an item whose subitems are hidden currently opens a separate focused window. This interrupts navigation and duplicates a window when the user expects to continue exploring that item's hierarchy in place.

## What Changes

- Make the macOS trailing disclosure arrow focus the current content presentation on the item when its subitems are hidden.
- Preserve `Open in New Window` as the explicit action for opening a focused child window.
- Keep focus state local to the current window and avoid changes to persisted document data.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `application-interface`: Define disclosure-arrow navigation for macOS items with hidden subitems.

## Impact

- Affected platform: macOS.
- Affected areas: macOS content presenter, disclosure-cell interaction, focus-navigation flow, and unit tests.
- No document-format, persistence, API, or dependency changes.
