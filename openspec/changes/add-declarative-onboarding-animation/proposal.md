## Why

Onboarding currently presents static feature illustrations, while reusable fake list items and their SwiftUI rendering already exist. A shared declarative animation mechanism will let authors demonstrate changes to a nested list without writing timing and playback code for every scene.

## What Changes

- Introduce onboarding scenarios with an initial collection of fake items and exactly two authoring operations: `Wait` and `Change`.
- Allow a single `Change` to update properties, insert, remove, or reorder multiple items together using ordinary Swift collection transformations.
- Define ordered playback with explicit durations, a standard ease-in-out transition curve, continuous looping from the original state until the presentation task is cancelled.
- Replace static feature pages with an internal OnboardingPage: animation above centered title/subtitle on both platforms, with a full-width footer below the macOS page. Keep separate previews for all three examples and the final vertical macOS window layout (ideal 680 × 600 pt).
- Provide a reusable scene view for iOS, iPadOS, and macOS, with explicit activation, cancellation, independent playback per presentation, and a static result when Reduce Motion is enabled.
- Add three separately looping reference scenarios and previews based on the existing fake list: subitem insertion with typing, collapse and expansion; sequential Projects/Today icon and color customization followed by checklist strikethrough; and two initially selected mirror-linked rows with simultaneous typing followed by shared strikethrough. Each scenario uses the previous scenario's final snapshot without replaying its timeline; mirrors prepares both linked rows before playback.

## Capabilities

### New Capabilities

- `onboarding/animation-scenarios`: Declarative scene authoring, preparation, timing, lifecycle, accessible playback, and rendering of fake onboarding items.

### Modified Capabilities

None outside this capability. Existing onboarding navigation and completion semantics remain applicable.

## Impact

- Implementation updates `CorePresentation`, its tests, and shared localization resources and iOS/macOS UI assembly boundaries; no new package dependency is required.
- Reuse `OnboardingItem`, `OnboardingItemBuilder`, and `OnboardingItemView`. Keep scenario definitions and prepared states in memory.
- Support the existing minimum deployment targets of iOS/iPadOS 17 and macOS 14.
- No changes to document data, `.nlist` serialization, migration, undo history, or persisted onboarding settings.
- Define public, main-actor Onboarding.Feature inside the Onboarding namespace. OnboardingFactory.build() creates all three features directly in Swift with stable feature IDs, English/Russian titles/subtitles from the shared string catalog, and concrete retained scenarios; remove JSON catalogs, decoding, and per-feature version limits.
- Extract OnboardingItemsFactory.makeItems(); use String item IDs with predefined named constants in the onboarding String extension and fresh UUID strings for other rows.
- Keep presentation eligibility in the platform coordinators: show every page on first launch or when the current app version is greater than the saved onboarding version. Preserve the existing UserDefaults key and completion writes.
- Bridge AppKit application activity into SwiftUI scenePhase so the selected animation runs, cancels, and restarts inside the macOS modal host.
- Fake scene transitions do not invoke document actions or emit user-action analytics. Preserve navigation, completion, settings persistence, and the single saved-version presentation gate while replacing static pages.
