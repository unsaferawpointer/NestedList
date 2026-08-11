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

- Each conversation must end with a proposed Git commit message.
- Use one of the following commit types: feature, fix, refactor, perf, docs, test, build, ci, style, chore, or revert.
- If all changes are limited to a single module, use the module name as the commit scope: [<type>](<module-name>): <message>.
- If changes affect multiple modules or the entire project, omit the module scope: [<type>]: <message>.
- Write the message in the imperative mood, start it with a capital letter, and do not end it with a period.

Examples:
[feat](Content): Add subitem navigation
[fix](Analytics): Preserve session identifier
[refactor]: Extract shared decoding logic
[docs]: Update contribution guidelines
[build](Core): Update package dependencies