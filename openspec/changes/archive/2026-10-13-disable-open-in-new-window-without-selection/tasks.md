## 1. macOS context-menu state

- [x] 1.1 Replace empty-selection hiding for `Open in New Window` with dynamic enabled-state evaluation.
- [x] 1.2 Use the existing AppKit menu validation path to apply the evaluated enabled state.
- [x] 1.3 Remove the temporary `ListAdapter` menu-update callback and its content view-controller consumer.

## 2. Verification

- [x] 2.1 Update macOS presenter tests to cover disabled without a selection and enabled with a selection.
- [x] 2.2 Update macOS UI-test coverage to assert that the visible command is disabled without a selection.
