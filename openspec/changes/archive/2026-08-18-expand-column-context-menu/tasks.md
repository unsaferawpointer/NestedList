## 1. Column menu surface

- [x] 1.1 Add column menu identifiers and shared menu-builder presentation for strikethrough, appearance heading, icon selection, and color selection.
- [x] 1.2 Add Column-localized picker titles and arrange the new actions with the existing edit, movement, and deletion commands.

## 2. Column actions

- [x] 2.1 Extend the Column interactor with root-item icon, color, and strikethrough operations using the existing shared mutation behavior.
- [x] 2.2 Route the new menu selections through the Column presenter to the existing icon and color pickers and persist confirmed choices.
- [x] 2.3 Reflect the root item's strikethrough state during menu validation and preserve normal-item completion behavior.
- [x] 2.4 Add `menu_item_click` analytics for the new selectable column menu actions using stable identifiers.

## 3. Verification

- [x] 3.1 Add Column presenter tests for menu composition, picker routing, strikethrough state, and analytics.
- [x] 3.2 Add Column interactor tests for root-only icon and color updates and descendant strikethrough behavior.
- [x] 3.3 Run the focused macOS test suite and build the macOS target.
