## Context

See [proposal.md](proposal.md) for the motivation. `ItemContent` is the shared content stored at every node of a document tree and already owns custom Codable handling. A document-wide display enum currently exposes `list` and `board` and is encoded using integer raw values.

## Goals / Non-Goals

**Goals:**

- Add a shared, item-level display preference without changing the hierarchy structure.
- Maintain decoding compatibility for existing `.nlist` documents.
- Adopt `columns` as the public name for the existing document-wide board mode.

**Non-Goals:**

- Render or select the new item-level presentation in iOS, iPadOS, or macOS UI.
- Change item hierarchy, drag-and-drop, undo behavior, or clipboard payloads beyond carrying the new model field through existing copy operations.
- Migrate existing files solely to rewrite a mode name.

## Decisions

### Use a value-type item display enum with `list` as its default

The preference belongs to `ItemContent`, since it describes how a particular item's descendants are presented. Its two modes are `list` and `columns`; constructors and decoding of documents that omit the field default to `list`.

This keeps the behavior consistent for all tree depths and preserves the current outline experience for every pre-existing item. Storing the property on a separate presentation-only object was considered, but it would not travel naturally with copied or serialized nodes and would introduce an unnecessary association by item identifier.

### Persist the preference as an optional addition to item data

The new preference is encoded with each item and decoded conditionally. New saves therefore preserve it, while documents written before this change remain readable without a document-version bump.

The existing copy and property-transfer paths must carry the field so copied subtrees retain their presentation preference. This is preferred over recomputing the preference from the parent, because each item owns an independent mode.

### Rename the document enum case without changing its stored representation

Replace the public `board` case with `columns` while retaining its existing integer raw value. Existing documents then decode as `columns`, and newly written columns documents remain compatible with prior readers that understand that raw value.

Using a new raw value or serialized string was considered, but would force a migration and could make current documents unreadable in earlier app versions without providing a user-facing benefit.

## Risks / Trade-offs

- [Older documents lack the new item field] → Decode a missing field as `list` and cover this with fixture-based tests.
- [Renaming a public enum case breaks source clients] → Treat the API rename as intentional and update all in-repository references; persisted compatibility is retained through the unchanged raw value.
- [Copied items lose their display preference] → Include the field in model copying and property transfer, with focused model tests.

## Migration Plan

1. Release readers that accept documents with and without an item display preference.
2. Preserve the document-level columns raw value used by the former board mode.
3. Allow documents to be saved normally; no eager rewrite or document-format version migration is required.
4. Roll back safely by removing the item field from newly written data only after confirming older readers ignore unknown item keys; documents without the field continue to decode as list.
