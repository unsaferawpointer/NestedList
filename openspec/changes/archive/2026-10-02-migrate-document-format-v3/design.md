## Context

The current `.nlist` persistence path encodes `DocumentNode` values as `Item` objects inside the versioned JSON envelope. The `Hierarchy` module already has a mirror-capable `Container` and `MirrorStore`, but the CoreModule persistence representation currently discards the distinction between an original item and a mirror. Version 3 will use a generic `DocumentNode<Value>` with `Container<ItemContent, UUID>` as its persisted value. The enum's synthesized Codable representation will provide explicit `item` and `mirror` JSON tags.

## Goals / Non-Goals

**Goals:**

- Make version `3.0.0` the write format for `.nlist` documents.
- Represent mirrors by a placement UUID and a direct `reference` UUID without copying item content.
- Read versions 1 and 2 through the existing migration path and construct the same current document model.
- Validate persisted mirror invariants before exposing the document to the application.
- Keep the change platform-independent across iOS, iPadOS, and macOS.

**Non-Goals:**

- Introducing new mirror creation, deletion, movement, or editing UI.
- Changing the JSON envelope, file extension, or document UTI.
- Changing the semantics of the existing `MirrorStore` operations.
- Adding synchronization between separate files or documents.

## Decisions

### Use generic document nodes with tagged containers

`DocumentNode` will become generic over its value. Version 3 persistence will use `DocumentNode<Container<ItemContent, UUID>>`; no separate persisted-node type will be introduced. `Container` will use synthesized Codable with explicit `item` and `mirror` tags, keeping the persisted distinction in the existing hierarchy abstraction and allowing `MirrorStore` to remain the source of mirror validation and resolution behavior.

An alternative would be adding `isMirror` and `reference` fields to `Item`, or inferring the enum case from the presence of `reference`. Both would make malformed and ambiguous values easier to accept and would weaken the existing `Container` abstraction.

### Use explicit enum tags as the discriminator

Version 3 values are encoded as either `{ "item": { "id": ..., "content": ... } }` or `{ "mirror": { "id": ..., "reference": ... } }`. The explicit tag avoids field-shape inference and uses synthesized Codable behavior for the enum payload.

### Keep migration at the JSON provider boundary

The provider will continue to inspect the envelope version before decoding content. Versions 1 and 2 will decode their existing original-item shape through the generic document node and convert those values into `Container.item`. Version 3 will decode tagged original and mirror values and validate the resulting hierarchy before returning `DocumentContent`.

Existing version-1 appearance migration remains unchanged. New saves always use `DocumentType.nlist.lastVersion == 3.0.0`.

### Treat invalid persisted mirrors as invalid documents

Missing targets, references to mirrors, duplicate element identifiers, and children under mirrors are structural document errors. They should fail the read atomically rather than produce an incomplete document or silently drop mirrors.

### Preserve old files, not old writer compatibility

The application will continue reading supported older files, but a saved file containing version 3 mirror semantics cannot be correctly read by an older application. The major version communicates this breaking writer change. Original-only files are also rewritten as version 3 after they are saved.

## Risks / Trade-offs

- [Older applications cannot read newly saved mirror documents] → Use major version `3.0.0` and retain the existing unknown-version handling in older readers.
- [A malformed reference can make an otherwise valid JSON file unreadable] → Validate all mirror invariants before returning document content and cover each failure with fixture-based tests.
- [Changing the persisted node value type can affect document APIs] → Keep public resolved-item APIs and platform document lifecycle code unchanged where possible; isolate the conversion in CoreModule persistence and document-model adapters.
- [Mirrors may be introduced into the model before dedicated UI exists] → Scope this change to persistence and shared domain readiness; do not add user-facing controls or analytics events here.

## Migration Plan

1. Raise the supported `.nlist` last version to `3.0.0`.
2. Add the version 3 original/mirror Codable representation and adapters to the existing document model.
3. Keep version 1 and version 2 decoding paths and convert their original-only trees into the new representation.
4. Add valid and invalid version 3 fixtures, plus round-trip and backward-compatibility tests.
5. Verify that opening and saving legacy fixtures writes version `3.0.0` without losing content, appearance, hierarchy, or order.

If implementation must be rolled back, version 3-capable code can still read versions 1 and 2. Existing applications released before this change remain able to read only documents saved without mirrors; no in-place rewrite of files is required until the user saves them.
