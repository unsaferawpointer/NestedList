## 1. Item display-mode model

- [x] 1.1 Add the `list` and `columns` item display modes and an `ItemContent` property that defaults to `list`.
- [x] 1.2 Propagate the item display preference through item initialization, copying, and property transfer paths.

## 2. Document compatibility

- [x] 2.1 Encode and conditionally decode the item display preference, defaulting missing values in existing `.nlist` documents to `list`.
- [x] 2.2 Rename the document display-mode API from `board` to `columns` while retaining its existing persisted raw value.
- [x] 2.3 Update all in-repository document display-mode references to use `columns`.

## 3. Verification

- [x] 3.1 Add CoreModule model tests for default, explicit, copied, and serialized item display preferences.
- [x] 3.2 Update document fixtures and serialization tests to prove older documents decode with item mode `list` and former board values decode as `columns`.
- [x] 3.3 Run the focused CoreModule test suite.
