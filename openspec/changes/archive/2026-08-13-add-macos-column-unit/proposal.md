## Why

The future macOS columns presentation needs an isolated unit for representing one column. Establishing the unit boundary now makes it possible to add its data and UI behavior incrementally without coupling it to the existing list unit.

## What Changes

- Add a macOS `Column` unit consisting of an assembly, interactor, presenter, and view controller.
- Add empty protocol interfaces for communication between the unit layers.
- Wire the concrete instances through the assembly while avoiding retain cycles.
- Do not add column rendering, document-storage access, user actions, menus, or changes to persisted data.

## Capabilities

### New Capabilities

- None; this change establishes internal scaffolding and has no observable user-facing behavior.

### Modified Capabilities

- None.

## Impact

- Affected platform and module: macOS application target.
- Adds source files under `macOS/macOS/Units/Column/`.
- Does not affect `.nlist` documents, existing item data, or iOS and iPadOS behavior.
