## 1. macOS disclosure navigation

- [x] 1.1 Route a hidden-subitems trailing disclosure action through the current content presentation's focus operation instead of the child-window creation flow.
- [x] 1.2 Preserve the explicit `Open in New Window` action and existing window-local focus navigation behavior.
- [x] 1.3 Report the disclosure activation with the existing `button_click` analytics event and a stable, non-content action identifier.

## 2. Verification

- [x] 2.1 Add macOS presenter tests that verify the disclosure arrow focuses the tapped item, does not open another window, and reports the expected analytics event.
- [x] 2.2 Add or update a test for focusing a hidden-subitems item with no visible descendants so the empty placeholder and navigation path remain available.
- [x] 2.3 Run the focused macOS test suite and `openspec validate focus-hidden-subitems-from-disclosure --strict`.
