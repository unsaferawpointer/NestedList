## Why

Keeping `Open in New Window` visible makes the command discoverable even before an item is selected. Disabling it without a selection communicates the prerequisite without changing the menu structure.

## What Changes

- Keep the macOS-only `Open in New Window` context-menu command visible when the outline has no effective selection.
- Disable the command when no item is selected; enable it when one or more items are selected.
- Preserve opening only the first selected item and existing menu-item analytics when the enabled command is invoked.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `application-interface`: Define the disabled state of the macOS `Open in New Window` context-menu command without a selection.

## Impact

- Affected platform: macOS only.
- Affected areas: content menu presentation, content view-controller menu state, presenter tests, and UI tests.
- No document format, persisted-data, public API, or dependency changes.
