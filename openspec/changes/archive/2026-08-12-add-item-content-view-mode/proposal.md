## Why

Every outline item needs to retain its own preferred presentation so that its children can be displayed either as a traditional list or as columns. The existing document-level `board` name should be aligned with the new, clearer `columns` terminology without making saved documents unreadable.

## What Changes

- Add an item-level display-mode property to `ItemContent` with the `list` and `columns` modes.
- Persist the selected item display mode in `.nlist` documents, defaulting items from older documents to `list`.
- Rename the document-level `board` display mode to `columns`, preserving the encoded representation of existing board documents.
- Apply the shared model and persistence behavior on iOS, iPadOS, and macOS; this change does not introduce a platform-specific view UI.

## Capabilities

### New Capabilities

- `item-content-view-mode`: Store and persist an item's list or columns display preference while retaining compatibility with existing documents.

### Modified Capabilities

- None.

## Impact

- Affected module: `CoreModule`, including `ItemContent`, document serialization, and model tests.
- The persisted document model gains an optional item field. Existing documents remain readable; documents whose top-level view is currently encoded as `board` continue to decode as `columns`.
- The public document view API replaces the `board` case with `columns`.
