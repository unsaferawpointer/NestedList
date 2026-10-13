## Why

People navigating a large outline need to inspect a selected item's descendants without losing their place in the current document window. The application already supports focused child windows through a disclosure control, but the same capability is unavailable from the item context menu.

## What Changes

- Add the macOS-only `Open in New Window` command to the item context menu.
- Enable the command when one or more items are selected; when multiple items are selected, open the first selected item in outline order.
- Reuse the existing focused-item child-window behavior, including the document association and focused-item title.
- Show the command only when the context menu has one or more selected items.
- Record the interaction using the existing `menu_item_click` analytics event and a stable command identifier.
- Do not change iOS or iPadOS behavior, the document format, or persisted document data.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `application-interface`: Define the macOS context-menu command and its focused-item window behavior.

## Impact

- Affected target: macOS only.
- Affected areas: shared content-menu identifier, macOS menu construction and localization, macOS content presenter and router integration, analytics coverage, and macOS unit/UI tests.
- No public API, dependency, `.nlist` format, or migration changes.
