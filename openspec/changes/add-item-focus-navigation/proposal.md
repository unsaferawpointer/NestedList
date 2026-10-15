## Why

Deep outlines are difficult to work with in one document window: opening a selected item currently requires a separate focused window, which loses the surrounding navigation context. A focused root and visible ancestor path let people concentrate on a subtree while moving back through its hierarchy without creating another window.

## What Changes

- Add a macOS content-view context-menu command that makes the selected item the focused root in the current content presentation.
- Add a bottom path control to macOS content views that retains the user's physical navigation route and lets the user return to any route component or the document root.
- Keep focus state local to the content presentation and do not persist it in a `.nlist` document.
- Exclude iOS/iPadOS interfaces from this change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `application-interface`: Define focused-root navigation and path control behavior for the macOS list document window.

## Impact

- Affected platform: macOS content views.
- Affected macOS components: content menu, content presenter/interactor, list view layout, localized strings, and analytics emission.
- Tests: unit coverage for focus navigation and path state; UI coverage only for context-menu availability and selection.
- No document format, persisted data, migration, or shared hierarchy-model changes.
