## 1. Shared model and persistence

- [x] 1.1 Remove the document and item `columns` view states and their `.nlist` serialization paths from CoreModule.
- [x] 1.2 Update CoreModule model and persistence tests for list-only document and item presentation state.

## 2. iOS and iPadOS list presentation

- [x] 2.1 Make the iOS document assembly build the existing list content unit without document-view selection.
- [x] 2.2 Remove the iOS Columns and Column presentation units and their obsolete target references.
- [x] 2.3 Update iOS tests to cover the list-only document presentation.

## 3. macOS list presentation

- [x] 3.1 Make the macOS document assembly build the existing list content unit without document-view selection.
- [x] 3.2 Remove the macOS Columns and Column units, their localization resources, their analytics emitters, and their unit tests.
- [x] 3.3 Remove the macOS columns feature gate, view switcher, and new-column toolbar behavior while retaining the standard new-item control.
- [x] 3.4 Update macOS tests for the list-only document window and toolbar.

## 4. Verification

- [x] 4.1 Confirm source, resources, tests, and project targets contain no Columns, Column, or columns-feature implementation references.
- [x] 4.2 Run focused CoreModule, iOS, and macOS test suites and build both application targets.
- [x] 4.3 Validate the OpenSpec change with `openspec validate remove-columns-interface --strict`.
