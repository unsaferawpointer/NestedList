# document-format Specification

## Purpose

Defines the `.nlist` JSON document format so NestedList can reliably preserve outline data on iOS, iPadOS, and macOS.

## Document Type

The document Uniform Type Identifier (UTType) is `dev.zeroindex.nested-list.doc`. It conforms to `public.data` and uses the `nlist` filename extension.

## JSON Format

A `.nlist` file is a JSON object with this envelope.[^json-data]

```json
{
	"version": "<major>.<minor>.<patch>",
	"content": {
		"uuid": "<document UUID>",
		"view": 0,
		"items": [<node>, ...]
	}
}
```

`content.uuid` and `content.view` are optional when reading. `view` is `0` for `list` and `1` for `columns`. Every node has a `value` object and can have a `children` array:

```json
{
	"value": {
		"uuid": "<item UUID>",
		"text": "Item text",
		"note": "Optional note",
		"options": 0,
		"view": 0
	},
	"children": [<node>, ...]
}
```

### Legacy format (version 1)

Version 1 represents each item's appearance with a required `style` object. The object has exactly one key: `item` or `section`. A section can carry an optional `icon` object.

```json
{
	"version": "1.0.0",
	"content": {
		"items": [
			{
				"value": {
					"uuid": "<item UUID>",
					"text": "Section",
					"options": 0,
					"style": {
						"section": {
							"icon": { "name": 10, "color": 3 }
						}
					}
				}
			}
		]
	}
}
```

### Current format (version 2)

Version 2 replaces `style` with optional `iconName` and `tintColor` integer fields on each item. New saves use this format and write `version` as `2.0.0`.

```json
{
	"version": "2.0.0",
	"content": {
		"uuid": "<document UUID>",
		"view": 1,
		"items": [
			{
				"value": {
					"uuid": "<item UUID>",
					"text": "Section",
					"options": 0,
					"iconName": 10,
					"tintColor": 3
				}
			}
		]
	}
}
```

[^json-data]: JSON data reference:

	- `version`: String selecting the format version. New saves use `major.minor.patch`; when reading, an optional leading `v` is accepted, a valid integer major component is required, and absent or non-integer minor and patch components are treated as `0`.
	- `content`: Object containing the document data.
	- `content.uuid`: Optional UUID string identifying the document. New v2 saves include it. An unreadable value is ignored when reading.
	- `content.view` and `value.view`: Optional integer view mode (`0` for `list`, `1` for `columns`); an omitted value is `list`.
	- `content.items` and `children`: Ordered arrays of tree nodes. `children` is optional.
	- `value`: Item object for a tree node.
	- `value.uuid`: Required UUID string identifying the item.
	- `value.text`: Required string containing the item text.
	- `value.note`: Optional string containing the item note.
	- `value.options`: Required integer bitset: `1` is strikethrough, `2` is the legacy marked value, and `4` hides subitems.
	- `value.style`: Required only in v1; an object with exactly one `item` or `section` key. A `section` can include `icon.name` and `icon.color` integer values. An unreadable optional `icon` is ignored.
	- `value.iconName` and `value.tintColor`: Optional v2 integer appearance values that replace v1 `style`. An unreadable optional appearance value is ignored.

## Requirements

### Requirement: Document type identification
The system SHALL identify `.nlist` documents with the UTType `dev.zeroindex.nested-list.doc`, which conforms to `public.data`, on iOS, iPadOS, and macOS.

#### Scenario: Open a document by type
- **WHEN** the operating system provides a document with UTType `dev.zeroindex.nested-list.doc`
- **THEN** the system recognizes it as a NestedList `.nlist` document

### Requirement: Versioned `.nlist` document envelope
The system SHALL store a `.nlist` document as a JSON object with a `version` string and a `content` object. New documents SHALL write `version` in `major.minor.patch` notation. When reading, the system SHALL accept an optional leading `v` and SHALL derive missing or non-integer minor and patch components as `0`, provided the major component is a valid integer. The `content` object SHALL contain the document's `items` tree and MAY contain its `view` and `uuid` properties.

#### Scenario: Read a versioned document
- **WHEN** a `.nlist` JSON document contains a valid `version` and a valid `content.items` tree
- **THEN** the system restores its document content

#### Scenario: Save a document
- **WHEN** the system saves a `.nlist` document
- **THEN** it writes the versioned JSON envelope using version `2.0.0`

#### Scenario: Read a version with a prefix or omitted components
- **WHEN** a document version has an optional leading `v` or omits its minor or patch component
- **THEN** the system derives the missing version components as `0` and attempts to read the document

#### Scenario: Read a document without an envelope field
- **WHEN** a `.nlist` JSON document omits `version`, `content`, or `content.items`
- **THEN** the system rejects the document as having an unexpected format

### Requirement: Hierarchical item representation
The system SHALL represent the outline in `content.items` as an ordered array of tree nodes. Each tree node SHALL contain a `value` item object and MAY contain a `children` array of tree nodes. The system SHALL preserve each node's parent-child relationship and sibling order when it reads or saves a document.

#### Scenario: Read nested items
- **WHEN** an item node contains descendant nodes in `children`
- **THEN** the system restores those nodes as children of that item in their stored order

#### Scenario: Save nested items
- **WHEN** a document contains root items and nested descendants
- **THEN** the saved `items` tree retains every parent-child relationship and sibling order

### Requirement: Common item properties
Each item `value` object SHALL contain a UUID string in `uuid`, text in `text`, and an integer option bitset in `options`. It MAY contain `note`, `view`, `iconName`, and `tintColor`. When `note` is absent, the system SHALL restore no note; when `view` is absent, it SHALL restore the `list` view.

#### Scenario: Read an item with optional content
- **WHEN** an item contains `note`, `view`, `iconName`, or `tintColor`
- **THEN** the system restores the available optional properties with that item

#### Scenario: Read an item without optional content
- **WHEN** an item omits `note`, `view`, `iconName`, and `tintColor`
- **THEN** the system restores no note, no icon or tint, and the `list` item view

#### Scenario: Read an item with an unreadable optional appearance value
- **WHEN** an item contains an unreadable optional `iconName`, `tintColor`, or legacy section icon
- **THEN** the system ignores that appearance value and continues decoding the item

#### Scenario: Read an unreadable optional document UUID
- **WHEN** `content.uuid` is absent or cannot be decoded as a UUID
- **THEN** the system restores the document without a document UUID

### Requirement: Document and item view values
The system SHALL represent both document-level `content.view` and item-level `value.view` as integers: `0` for `list` and `1` for `columns`. When `content.view` is absent, the system SHALL restore the document with the `list` view.

#### Scenario: Read columns views
- **WHEN** a document or item stores `view` as `1`
- **THEN** the system restores its view as `columns`

#### Scenario: Read an omitted document view
- **WHEN** a document omits `content.view`
- **THEN** the system restores the document with the `list` view

### Requirement: Backward-compatible document reading
The system SHALL maintain backward compatibility with valid `.nlist` documents written in earlier supported formats on iOS, iPadOS, and macOS. It SHALL restore their hierarchy, common item data, and available appearance semantics, then save documents using the current format. The format differences that require migration are defined by the JSON examples and data reference.

#### Scenario: Open a document in the legacy format
- **WHEN** the system opens a valid document matching the legacy JSON example
- **THEN** it restores the document content and its available appearance semantics

#### Scenario: Open a document in the current format
- **WHEN** the system opens a valid document matching the current JSON example
- **THEN** it restores the document content without requiring legacy-only fields

#### Scenario: Save content read from a legacy document
- **WHEN** the system saves content that was read from a valid legacy document
- **THEN** it writes a document using the current JSON format while preserving the content and appearance semantics

### Requirement: Breaking format versioning
The system SHALL increase the major component of the `.nlist` document `version` for every breaking change to the persisted document format. A breaking change includes any change that prevents an earlier application version from correctly decoding a newly written document. For backward-compatible persisted format changes, the system SHALL increase the minor component once per application release that contains one or more such changes.

#### Scenario: Introduce a breaking document change
- **WHEN** a change modifies the persisted `.nlist` structure or semantics so that an earlier application version cannot correctly decode a newly saved document
- **THEN** the new document format uses a higher major version

#### Scenario: Make a backward-compatible document change
- **WHEN** a change preserves the ability of earlier application versions to correctly decode a newly saved document
- **THEN** it does not require a major document version increase and requires a minor version increase for that release

#### Scenario: Make multiple backward-compatible document changes in one release
- **WHEN** an application release contains multiple backward-compatible changes to the persisted `.nlist` format
- **THEN** the document minor version increases exactly once for that release

### Requirement: Document format validation
The system SHALL reject a `.nlist` document whose declared major format version is newer than the application's supported `lastVersion` with the `unknownVersion` error. It SHALL reject a damaged JSON file or a document whose envelope or required document fields cannot be decoded with the `unexpectedFormat` error. Unreadable optional appearance fields and `content.uuid` SHALL NOT by themselves cause this error.

#### Scenario: Read a document newer than the application's last version
- **WHEN** the system opens a `.nlist` document whose major format version is greater than the application's `lastVersion`
- **THEN** it rejects the document with the `unknownVersion` error

#### Scenario: Read a damaged document
- **WHEN** the system opens a `.nlist` file that is not valid JSON or does not contain a decodable document envelope
- **THEN** it rejects the document with the `unexpectedFormat` error

#### Scenario: Read invalid content for its format
- **WHEN** a document's envelope version is supported but its required content structure cannot be decoded
- **THEN** it rejects the document with the `unexpectedFormat` error
