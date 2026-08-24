# analytics Specification

## Purpose

Defines the event schema and delivery behavior used to report application activity from NestedList on iOS, iPadOS, and macOS.

## Requirements

### Requirement: Stable analytics event schema
The system SHALL report analytics events with a stable event name, an `area` property identifying the product area, and typed event properties. Event names and property keys used by the analytics backend SHALL remain stable unless changed through an explicit analytics schema migration.

The supported common event names and required properties SHALL be:

- `button_click`
	- `id: String`
- `menu_item_click`
	- `id: String`
- `dropdown_item_click`
	- `id: String`
	- `value: String`
- `toggle_click`
	- `id: String`
	- `value: Bool`
- `screen_show`
	- No required properties.
- `drag_drop_move`
	- `items_count: Int`
- `drag_drop_copy`
	- `items_count: Int`
- `drag_drop_insert`
	- `items_count: Int`
	- `content_type: String`

Feature-specific properties MAY supplement the common properties when they describe the reported interaction. Their values SHALL be machine-readable and stable; identifiers for controls and areas SHALL be descriptive and stable.

#### Scenario: Report a settings toggle
- **WHEN** a user changes a settings toggle
- **THEN** the system reports a `toggle_click` event with the settings area, a stable control `id`, and the selected Boolean `value`

#### Scenario: Report a drag-and-drop insertion
- **WHEN** external or pasteboard content is inserted through drag and drop
- **THEN** the system reports a `drag_drop_insert` event with the number of inserted items and the inserted content type

### Requirement: Application interaction coverage
The system SHALL report the supported user interactions and screen presentations from the areas that emit analytics events: onboarding, content, document, settings, item details, icon picker, color picker, target destination, reorder, and the macOS column and columns interfaces.

The system SHALL report successful and failed document reads as `document_read` and `document_read_error` respectively. A successful document-read event SHALL include the document type. A failed document-read event SHALL include a stable failure reason.

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
- `document`
	- `document_read`: A document is read successfully.
		- `type: String` is the stable document type identifier.
	- `document_read_error`: A document cannot be read.
		- `reason: String` is `unexpected_format` or `unknown_version`.
	- `button_click` (macOS): A document view control is selected.
		- `id: String` begins with `document-view-` and identifies the selected view.
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
	- `button_click`: The picker is cancelled or a color is selected.
		- `id: String` is `cancel` or `select_color`.
		- `raw_value: Int` is the selected color value; `none` represents no selection.
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
- `column` (macOS)
	- `menu_item_click`: A column menu item is selected.
		- `id: String` identifies the command.
- `columns` (macOS)
	- `screen_show`: The columns interface is shown; no additional properties.
	- `button_click`: A column is created.
		- `id: String` is `new-column`.

#### Scenario: Report an onboarding interaction
- **WHEN** a user selects the Get Started button on the onboarding screen
- **THEN** the system reports a `button_click` event in the `onboarding` area with `id` `get_started` and the current page `index`

#### Scenario: Report a macOS content copy
- **WHEN** a user copies items by dragging them in the macOS content outline
- **THEN** the system reports a `drag_drop_copy` event in the `content` area with the number of copied items

### Requirement: Anonymous event enrichment
The system SHALL enrich every analytics event with an anonymous installation identifier, a process-session identifier, the session start time, the event creation time, a unique event insertion identifier, and available environment metadata.

The installation identifier SHALL persist across application launches. The session identifier and session start time SHALL remain the same for the lifetime of one application process and SHALL be regenerated for a new process. Environment metadata SHALL include platform, operating-system name and version, and application version; it SHALL include region, country, and language when available.

#### Scenario: Report events in one session
- **WHEN** multiple events are reported during one application process
- **THEN** they contain the same anonymous installation identifier, session identifier, and session start time

#### Scenario: Report an event on a new launch
- **WHEN** the application starts in a new process and reports an event
- **THEN** the event retains the stored anonymous installation identifier and uses a new session identifier and session start time

### Requirement: Batched Amplitude delivery
The system SHALL submit analytics events to the Amplitude HTTP API V2 as JSON. Each delivered event SHALL use its stable event name as the Amplitude event type, include `area` in event properties, and include the enriched identifiers and metadata.

The system SHALL queue events in memory and automatically attempt delivery when ten events are queued. An explicit flush SHALL attempt delivery of all queued events in batches of at most ten, preserving their queue order.

#### Scenario: Reach the automatic batch threshold
- **WHEN** the tenth queued analytics event is recorded
- **THEN** the system attempts to deliver the queued batch to Amplitude

#### Scenario: Flush queued events
- **WHEN** the application explicitly flushes analytics events
- **THEN** the system attempts to deliver every queued event in ordered batches of no more than ten events

### Requirement: Delivery failure and queue retention
The system SHALL remove a delivered batch from the in-memory queue only after Amplitude accepts the request with a successful HTTP status. If a batch cannot be delivered, the system SHALL retain that batch and any later queued events for a later flush attempt.

The system SHALL bound the in-memory queue to 100 events. When adding an event would exceed that limit, the system SHALL discard the oldest queued events first.

#### Scenario: Amplitude rejects a batch
- **WHEN** Amplitude returns a non-successful response or the request fails
- **THEN** the system retains the failed batch and does not attempt later queued batches during that flush

#### Scenario: Queue exceeds its retention limit
- **WHEN** a new event causes the in-memory queue to contain more than 100 events
- **THEN** the system discards the oldest queued events until 100 events remain
