## 1. Declarative authoring and preparation

- [x] 1.1 Add internal OnboardingScenario, its result builder, and separate Wait/Change files; support sequential expressions, loops, optional groups, and reusable operation groups.
- [x] 1.2 Apply synchronous collection transformations once during preparation and retain initial/final snapshots, target steps, and scenario-instance UUIDs without transformation closures.
- [x] 1.3 Validate nonnegative durations, unique String item identities, and positive-duration nonempty loops using assertions; return an empty static fallback with assertions disabled.
- [x] 1.4 Test ordered/dependent and atomic collection changes, identity-preserving reorder, explicit hierarchy, empty states, assertion diagnostics, and nonasserting fallback.

## 2. Playback and SwiftUI lifecycle

- [x] 2.1 Implement one main-actor observable player with injectable monotonic sleep, step-start publication, duration consumption, and continuous reset/replay from prepared snapshots.
- [x] 2.2 Handle zero-duration changes, positive-duration no-op changes, trailing final holds, and empty timelines; check cancellation before each step and in the outer loop without redundant post-sleep checks.
- [x] 2.3 Render the existing List and item views with stable identities, transparent rows, disabled hit testing, and one ease-in-out transaction per target; disable animation for resets and immediate changes.
- [x] 2.4 Key scene content by scenario identity and gate its structured task on explicit activation, active scenePhase, and Reduce Motion; render the final snapshot directly for Reduce Motion.
- [x] 2.5 Test durations, repeated iterations without reevaluating transformations, cancellation during waits/changes, restart, replacement, and independent players using a controllable sleeper.

## 3. Shared fixtures and reference scenarios

- [x] 3.1 Extract OnboardingItemsFactory.makeItems(); use String item IDs, named String constants, preserved explicit builder IDs, and fresh UUID strings for other rows.
- [x] 3.2 Provide an independent subitems scenario: selected child insertion under App Update, character typing, and collapse/restore of all authored descendants with preserved identities.
- [x] 3.3 Provide an independent customization scenario based on the prior final snapshot: Projects squareStack with unchanged color, then Today calendar/red, then checklist strikethrough and completed appearance.
- [x] 3.4 Provide an independent mirrors scenario with both selected blank/caret rows visible initially, simultaneous typing, and shared completion while retaining both selections.
- [x] 3.5 Add per-scenario animated previews plus inactive and static-final previews; retain prepared scenarios and test continuity, renamed/duplicate titles, descendant restoration, ordering, and mirror synchronization.

## 4. Production features and localization

- [x] 4.1 Nest public main-actor Feature in Onboarding; retain title/subtitle and the concrete scenario selected by the typed subitems/customization/mirrors enum.
- [x] 4.2 Build the complete ordered feature array directly in OnboardingFactory.build() without version/Bundle parameters, JSON loading, decoding, throwing, or per-feature version limits.
- [x] 4.3 Move all six English/Russian page strings to OnboardingLocalizable.xcstrings and remove platform/test onboarding JSON resources and unused test resource declarations.
- [x] 4.4 Update platform assemblies and previews, remove static PageView, and test scenario mapping plus retained scenario identity on copy and navigation.

## 5. Vertical pages and platform integration

- [x] 5.1 Compose OnboardingPage vertically on both platforms: animation above centered wrapping title/subtitle, natural row sizing, no zoom/focus scrolling, and retained per-scenario previews.
- [x] 5.2 On macOS distinguish the illustration with textBackgroundColor; keep caption and full-width footer on the same material without a divider, illustration card, or footer overlay.
- [x] 5.3 Use macOS ideal size 680 × 600 points with width bounds 640–820 and height bounds 560–640; keep the illustration content bounded to 420 points and page previews at 680 × 540.
- [x] 5.4 Gate iOS playback to the selected incomplete page and bridge actual AppKit application activity into SwiftUI scenePhase for modal macOS playback/cancellation/restart.
- [x] 5.5 Preserve navigation/completion and the existing saved-version gate: show all pages on first launch or a newer current version, skip equal/older or missing current versions, and persist the current version on completion/skip.

## 6. Verification and isolation

- [x] 6.1 Run focused onboarding regressions and macOS coordinator tests covering first launch, upgrades, equal/newer saved versions, and missing current versions.
- [x] 6.2 Build complete macOS and iOS Simulator applications at the existing deployment targets; review the final vertical pages with localized text, visible mirror rows, and full-width navigation.
- [x] 6.3 Verify fake scene playback has no document, undo, pasteboard, drag/drop, or simulated user-action analytics side effects; preserve existing analytics event schemas and settings keys.
- [x] 6.4 Check tabs, labeled conformance/private extensions, AAA tests, strict OpenSpec validation, and whitespace.

## Implementation baseline and verification evidence

This checklist describes the final implementation committed as `3855b822654a2fda54499a0410b431acca431a0a`. It replaces the chronological experiment log with the delivered design. Abandoned horizontal layouts, fixed illustration columns, footer overlays, automatic focus/zoom, item UUID APIs, and JSON/version-filtering APIs are not outstanding tasks or delivered requirements.

The following evidence is retained from the implementation session; executable checks are not rerun for this documentation-only reconciliation:

- The final focused onboarding suite passed 34 tests in five suites after removal of obsolete version-filtering cases. The focused macOS coordinator suite passed seven tests, including parameterized equal/newer saved versions.
- Complete signed macOS Debug and iOS Simulator builds succeeded after restoration of the vertical layout.
- The final macOS first page was reviewed in the actual modal assembly at its 680-point ideal width. Customization/mirrors were reviewed at the 640 × 560 minimum with Russian captions; rows, centered text, and footer fit without overlap.
- Earlier runtime review confirmed AppKit activity cancellation/restart, independent playback, and equivalent static-final preview rendering. Debug assertion and Release fallback checks were performed during preparation work; these records do not imply a new final-commit Release test run.
- No document format, persisted settings schema, onboarding_version key, or analytics event/payload changes were introduced.
