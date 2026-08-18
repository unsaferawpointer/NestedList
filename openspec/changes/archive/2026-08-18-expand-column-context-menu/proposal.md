## Why

The macOS column header menu cannot change the appearance or completion state of a column, even though a column is represented by a regular outline item. Users need the same core actions available for a list item when working with a column.

## What Changes

- Extend the macOS column header context menu with actions to toggle strikethrough, select an icon, and select a color.
- Apply each action to the column's root item and immediately reflect the resulting appearance in the column header.
- Record each column-menu selection using the established `menu_item_click` analytics event.
- Preserve the existing movement, editing, and deletion actions in the menu.

## Capabilities

### New Capabilities

- `column-context-menu`: Provide appearance and completion actions for macOS column headers.

### Modified Capabilities

- None.

## Impact

- Affected platform: macOS.
- Affected code: the Column unit's menu identifiers, presenter, interactor, localization, analytics, and tests; shared icon and color pickers are reused.
- The document format and persisted data model do not change: columns use the existing item icon, tint-color, and strikethrough properties.
