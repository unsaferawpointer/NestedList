# column-context-menu Specification

## Purpose

Lets macOS users apply the same core item appearance and completion actions to a column directly from its header menu.

## Requirements

### Requirement: Column header provides item appearance actions

The macOS column header context menu SHALL offer actions to select an icon and select a color for the column's root item, alongside the existing column actions.

#### Scenario: Select an icon for a column

- **WHEN** the user selects the icon action in a column header menu and confirms an icon
- **THEN** the selected icon is assigned to that column's root item and displayed in the column header

#### Scenario: Select a color for a column

- **WHEN** the user selects the color action in a column header menu and confirms a color
- **THEN** the selected color is assigned to that column's root item and displayed in the column header

#### Scenario: Cancel an appearance selection

- **WHEN** the user dismisses the icon or color picker without confirming a selection
- **THEN** the column's existing appearance remains unchanged

### Requirement: Column header provides strikethrough action

The macOS column header context menu SHALL offer a strikethrough action for the column's root item and SHALL display its current state.

#### Scenario: Mark a column as strikethrough

- **WHEN** the user selects the strikethrough action for an unstruck column
- **THEN** the column root and its descendants become strikethrough and the header title is rendered strikethrough

#### Scenario: Remove strikethrough from a column

- **WHEN** the user selects the strikethrough action for a struck column
- **THEN** the column root and its descendants no longer use strikethrough and the header title is rendered without strikethrough

### Requirement: Column menu actions are measured

The system SHALL record a `menu_item_click` event with a stable action identifier whenever a user selects an appearance or strikethrough action from a column header menu.

#### Scenario: Track a column appearance action

- **WHEN** the user selects an icon, color, or strikethrough action from a column header menu
- **THEN** the system records `menu_item_click` with the selected action's stable identifier
