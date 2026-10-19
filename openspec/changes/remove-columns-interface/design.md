## Context

The iOS and macOS targets each contain a Columns presentation unit and supporting Column child unit. macOS also exposes a view switcher and an always-disabled feature gate. The shared document model still defines and serializes a `columns` view value at document and item levels, but no version that includes this feature has been released. See proposal.md for motivation and the delta specifications for required behavior.

## Goals / Non-Goals

**Goals:**

- Reduce every supported platform document presentation to the existing list content unit.
- Remove the Columns state from the shared model and `.nlist` representation before it becomes persisted user data.
- Remove target-only code, resources, tests, and analytics that exist solely for Columns.

**Non-Goals:**

- Changing the shared hierarchy structure, item data unrelated to view state, undo semantics, or drag-and-drop behavior.
- Migrating or preserving development-only documents that use the removed Columns state.
- Introducing a replacement multi-pane interface.

## Decisions

### Remove Columns from the model and document format

`DocumentContent.ContentView.columns` and `ItemContent.View.columns` are removed, together with their serialization and tests. New documents and items use list presentation only; decoding or encoding does not preserve a Columns value. Because Columns has not shipped, the project does not add a migration or fallback behavior for development-only data.

Alternative considered: retain Columns as an opaque legacy value. That would create a permanent compatibility contract for an unreleased feature and retain model complexity with no user benefit.

### Remove UI-owned Columns code from both targets

The iOS target will remove its Columns and Column units and always build the table content presentation. The macOS target will remove Columns and Column units, their localization resources and unit tests, and the feature provider that exists solely to gate Columns. The document toolbar will retain its standard new-item action and lose view-selection and new-column controls.

Alternative considered: leave disabled assemblies and the state model in place. That keeps dead code and an inactive product branch instead of removing it before release.

### Remove unreachable analytics definitions and emissions

Column and Columns analytics producers are removed with their UI units. The analytics specification stops advertising their areas and events; no compatibility handling is needed for historical product data because the events were never released.

Alternative considered: retain deprecated event definitions. They would imply the product supports interactions that do not exist.

## Risks / Trade-offs

- [Development-only documents contain a Columns value] → Treat them as unsupported test data; recreate them as list documents if needed.
- [Removing shared model cases leaves target references behind] → Build both application targets and search all modules for obsolete Columns references.
- [Removing target files leaves project resources behind] → Verify the filesystem-synchronised Xcode targets, localization resources, and target test sources after cleanup.
- [A user loses the former multi-column workflow] → No released user has received that workflow; focused item windows and macOS in-place focus remain separate list-based navigation features.

## Migration Plan

No migration, compatibility fallback, or deployment sequencing is needed. The feature has not been released. Rollback restores the removed code from source control before release.
