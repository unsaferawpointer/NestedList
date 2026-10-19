## MODIFIED Requirements

### Requirement: Application interaction coverage
The system SHALL report the supported user interactions and screen presentations from the areas that emit analytics events: onboarding, content, document, settings, item details, icon picker, color picker, item picker, target destination, and reorder.

The system SHALL report successful and failed document reads as `document_read` and `document_read_error` respectively. A successful document-read event SHALL include the document type. A failed document-read event SHALL include a stable failure reason.

The system SHALL report opening Settings from the document interface as a `button_click` event with the stable identifier `settings`.

#### Scenario: Show an application screen
- **WHEN** a supported analytics-producing screen becomes visible
- **THEN** the system reports a `screen_show` event in that screen's stable area

#### Scenario: Read a document successfully
- **WHEN** the application reads a document successfully
- **THEN** the system reports a `document_read` event in the `document` area with the document type

#### Scenario: Fail to read a document
- **WHEN** the application cannot read a document because of an unsupported version or invalid format
- **THEN** the system reports a `document_read_error` event in the `document` area with a machine-readable failure reason

### Requirement: Area-specific event definitions
The system SHALL use the following area-specific event definitions. An event SHALL include all listed properties in addition to the common event envelope.

- `onboarding`
	- `screen_show`: Onboarding is shown.
		- `total_count: Int` is the number of onboarding pages.
	- `button_click`: An onboarding button is selected.
		- `id: String` is one of `back`, `skip`, or `get_started`.
		- `index: Int` is the current page index.
- `content`
	- `screen_show`: A content document is displayed.
		- `depth: Int`, `total_count: Int`, and `is_root: Bool` describe the displayed outline.
	- `menu_item_click`: A context or application-menu item is selected.
		- `id: String` identifies the menu command.
		- `source: String` identifies the menu surface.
	- `button_click`: A content control is selected.
		- `id: String` identifies the control; showing hidden subitems uses `show_subitems`. On macOS, opening an item by double-click uses `open_item`.
		- `source: String` identifies the control surface.
	- `drag_drop_move`: Items are moved.
		- `items_count: Int` is the number moved.
	- `drag_drop_insert`: External or pasteboard content is inserted.
		- `items_count: Int` is the number created.
		- `content_type: String` identifies the inserted content.
	- `drag_drop_copy` (macOS): Items are copied by drag and drop.
		- `items_count: Int` is the number copied.
	- `inline_edit_finish` (macOS): Inline editing of an item is completed.
		- `title_length: Int` is the length of the resulting title.
		- `note_length: Int` is the length of the resulting note and is omitted when no note exists.
- `document`
	- `button_click`: The document Settings control is selected.
		- `id: String` is `settings`.
	- `document_read`: A document is read successfully.
		- `type: String` is the stable document type identifier.
	- `document_read_error`: A document cannot be read.
		- `reason: String` is `unexpected_format` or `unknown_version`.
- `settings`
	- `screen_show`: Settings is shown; no additional properties.
	- `button_click`: A settings action is selected.
		- `id: String` is `rate_app` or `contact_developer`.
	- `dropdown_item_click`: A settings dropdown item is selected.
		- `id: String` is `icon_color`.
		- `value: String` is the selected value.
	- `toggle_click`: A settings toggle is changed.
		- `id: String` is `completion_behaviour` or `sound_effects`.
		- `value: Bool` is its selected state.
- `item_details`
	- `screen_show`: Item details is shown.
		- `initial_text_length: Int` and `mode: String` describe the initial state.
	- `button_click`: The detail editor is dismissed or saved.
		- `id: String` is `cancel` or `save`.
- `icon_picker`
	- `screen_show`: The icon picker is shown; no additional properties.
	- `button_click`: The picker is cancelled or an icon is selected.
		- `id: String` is `cancel` or `select_icon`.
		- `raw_value: Int` is the selected icon value; `none` represents no selection.
- `color_picker`
	- `screen_show`: The color picker is shown; no additional properties.
	- `button_click`: The picker is cancelled or an icon is selected.
		- `id: String` is `cancel` or `select_color`.
		- `raw_value: Int` is the selected color value; `none` represents no selection.
- `item_picker`
	- `screen_show`: The item picker is shown.
		- `items_count: Int` is the number of items accepted by the picker filter.
	- `button_click`: The item picker is cancelled or an item is selected.
		- `id: String` is `cancel` or `select_item`.
		- The selected item's identifier SHALL NOT be included in analytics parameters.
- `target_destination`
	- `screen_show`: The target-destination screen is shown.
		- `available_items_count: Int` and `unavailable_items_count: Int` describe available destinations.
	- `button_click`: A destination is selected or the screen is closed.
		- `id: String` is `select_root`, `select_item`, or `close`.
- `reorder`
	- `screen_show`: The reorder screen is shown.
		- `items_count: Int` is the number of reorderable sibling items.
	- `button_click`: The reorder screen is closed.
		- `id: String` is `close`.
	- `drag_drop_move`: An item is reordered.
		- `items_count: Int` is the number moved.

#### Scenario: Report an onboarding interaction
- **WHEN** a user selects the Get Started button on the onboarding screen
- **THEN** the system reports a `button_click` event in the `onboarding` area with `id` `get_started` and the current page `index`

#### Scenario: Report a macOS content copy
- **WHEN** a user copies items by dragging them in the macOS content outline
- **THEN** the system reports a `drag_drop_copy` event in the `content` area with the number of copied items
