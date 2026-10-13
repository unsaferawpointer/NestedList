## 1. macOS context-menu command

- [x] 1.1 Add the macOS-only `open-in-new-window` content-menu identifier without changing iOS or iPadOS handling.
- [x] 1.2 Add English and Russian localizations for `Open in New Window` and build its `macwindow.on.rectangle` menu item.
- [x] 1.3 Insert the command after the creation commands and before item-editing commands in the macOS item context menu.

## 2. Focused-window action

- [x] 2.1 Route the command through the existing focused-window router operation using the first effective selected item.
- [x] 2.2 Omit the command when no item is effectively selected and report it through the existing `menu_item_click` path with the stable command identifier.

## 3. Verification

- [x] 3.1 Add macOS presenter tests for routing only the first selected item and for the analytics payload.
- [x] 3.2 Update macOS UI tests to verify the command's absence without a selection, localized title with a selection, and focused child-window presentation.
