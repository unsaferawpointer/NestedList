## 1. Focus navigation state

- [x] 1.1 Remove in-place-focus configuration so focus navigation is standard for macOS content assemblies and recover deleted focused roots at the deepest existing route component.
- [x] 1.2 Extend the macOS content interactor/presenter flow to change the active root, build the ordered physical ancestor path, and recover a deleted focused root at the deepest existing route component.
- [x] 1.3 Update storage observation to use the current active root, recover at the deepest valid physical route component, and preserve root-relative editing, paste, and drag-and-drop operations.
- [x] 1.4 Replace the single focused-root state with a window-local physical navigation route that restores route components and recovers safely from deleted route scopes. Mirrors do not become focused roots.

## 2. macOS list interface

- [x] 2.1 Add the localized `Focus` context-menu command to macOS content outlines, its stable identifier, selection validation, first-selected-item behavior, and existing menu-item analytics reporting.
- [x] 2.2 Add the macOS content view's bottom path control, render the document and item path components, handle component navigation, and report the path-control button click with the existing analytics event type.
- [x] 2.3 Constrain the list scroll view, placeholder, and path control so navigation remains available for an empty focused subtree.

## 3. Verification

- [x] 3.1 Add macOS unit tests for focus-root selection, ancestor and document-root navigation, deletion recovery, shared content behavior, and analytics identifiers.
- [x] 3.2 Add macOS unit tests that prevent focusing a mirror and preserve the physical navigation route.
- [ ] 3.3 Update macOS UI tests only for the context menu: verify `Focus` is disabled without selection and enabled and invocable with a selected item.
- [x] 3.4 Run the focused macOS test suite and `openspec validate add-item-focus-navigation --strict`.
