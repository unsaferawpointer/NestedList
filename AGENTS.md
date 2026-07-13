## Style guide

- Tabs must be used for indentation instead of spaces.
- Protocol requirements should be implemented in a dedicated extension, with that extension clearly labeled using a comment.
- Private methods should be placed in a separate extension.
- When defining a SwiftUI view, View protocol conformance should be implemented in a separate extension.

## Analytics

### User Actions

* `button_click` — any button tap (`id: String`).
* `menu_item_click` — any context menu item selection (`id: String`).
* `dropdown_item_click` — any dropdown item selection (`id: String`, `value: String`).
* `toggle_click` — any toggle selection (`id: String`, `value: Bool`).

### Drag and Drop

* `drag_drop_move` — items moved through drag and drop (`items_count: Int`).
* `drag_drop_copy` — items copied through drag and drop (`items_count: Int`).
* `drag_drop_insert` — external or pasteboard content inserted through drag and drop (`items_count: Int`, `content_type: String`).

### Screen Views

* `screen_show` — any screen presentation (`area: String`).

### Naming

* Use stable, descriptive values for `id` and `area`.
* Do not introduce custom event names for these event types.


## Workflow

- Each conversation must end with a proposed git commit message.
