# item-cell-appearance Specification

## Purpose

Defines how item data is presented by an item cell on iOS, iPadOS, and macOS.

## Requirements

### Requirement: Leaf state
The cell SHALL present the item text as its title. A leaf SHALL use the preferred body style; a non-leaf SHALL use the preferred headline style.

#### Scenario: Present a leaf
- **WHEN** `isLeaf` is `true`
- **THEN** the cell presents the title using the body style

#### Scenario: Present a non-leaf
- **WHEN** `isLeaf` is `false`
- **THEN** the cell presents the title using the headline style

### Requirement: Strikethrough state
An item with strikethrough SHALL use a struck-through disabled title and a monochrome tertiary icon. Without strikethrough, the title SHALL use the primary color without strikethrough.

#### Scenario: Present an item with strikethrough
- **WHEN** the item uses strikethrough
- **THEN** the cell presents a struck-through disabled title and a monochrome tertiary icon

#### Scenario: Present an item without strikethrough
- **WHEN** the item does not use strikethrough
- **THEN** the cell presents a primary title without strikethrough

### Requirement: Subtitle state
When the item has a note, the cell SHALL present its text as a subtitle using the preferred callout style, secondary color, and no strikethrough. Without a note, the cell SHALL omit the subtitle. On macOS, the row height SHALL adapt to the subtitle state.

#### Scenario: Present a subtitle
- **WHEN** the item has a note
- **THEN** the cell presents the note as a secondary callout subtitle without strikethrough

#### Scenario: Omit a subtitle
- **WHEN** the item has no note
- **THEN** the cell has no subtitle

### Requirement: Icon state
The cell SHALL use the filled form of the selected icon or the default point icon when no icon can be mapped. Without strikethrough, an application-wide icon color SHALL override the item tint; otherwise the icon SHALL use its preferred appearance for the item tint or a monochrome item tint when no preferred appearance is available.

#### Scenario: Present a selected icon
- **WHEN** the item icon can be mapped
- **THEN** the cell presents its filled form

#### Scenario: Present the default icon
- **WHEN** the item icon cannot be mapped
- **THEN** the cell presents the default point icon

#### Scenario: Apply an application-wide icon color
- **WHEN** the item does not use strikethrough and an application-wide icon color is configured
- **THEN** the cell presents a monochrome icon using that color

#### Scenario: Apply the item tint
- **WHEN** the item does not use strikethrough and no application-wide icon color is configured
- **THEN** the cell presents the icon using its preferred appearance for the item tint or a monochrome item tint as fallback

### Requirement: Hidden-subitems state
The cell SHALL present a trailing disclosure if and only if the item is configured to hide its subitems.

#### Scenario: Present a trailing disclosure
- **WHEN** the item hides its subitems
- **THEN** the cell presents a trailing disclosure

#### Scenario: Omit a trailing disclosure
- **WHEN** the item does not hide its subitems
- **THEN** the cell omits the trailing disclosure
