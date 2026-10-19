## Why

Columns were developed only in unreleased builds and are no longer part of the product direction. Removing them completely keeps NestedList focused on its list outliner and eliminates inactive UI, model, persistence, and analytics paths before they become a compatibility obligation.

## What Changes

- **BREAKING** Remove the columns document interface, its controls, and its column-specific interactions from iOS, iPadOS, and macOS.
- **BREAKING** Remove the `columns` document and item view state from the shared data model and `.nlist` serialization; only the list presentation remains supported.
- Remove macOS column and columns analytics emissions and their documented interaction areas.
- Do not provide migration or compatibility fallback because no version containing Columns has been released.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `application-interface`: Define list-only document presentation and remove columns-specific interface requirements.
- `analytics`: Remove column and columns UI analytics areas and events.
- `data-model/outline-document`: Remove columns view state from the document and item model.

## Impact

- Affected platforms: iOS, iPadOS, and macOS.
- Affected modules: CoreModule plus the iOS and macOS application targets, including the macOS document toolbar, feature gate, localization, tests, and analytics emitters.
- The `.nlist` format no longer represents the `columns` view value. No migration or backwards-compatibility work is required because Columns was never released.
