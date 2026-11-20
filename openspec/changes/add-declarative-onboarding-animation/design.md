## Context

See `proposal.md` for motivation and `specs/onboarding/animation-scenarios/spec.md` for the behavior contract.

`CorePresentation/Onboarding` already contains `OnboardingItem`, `OnboardingItemBuilder`, `OnboardingItemView`, and an `OnboardingItemsFactory.makeItems()` fixture. The item is an equatable value with a String ID, text, icon, hierarchy indicators, indentation, and selection. The builder generates a fresh UUID string by default; build(id:) preserves an explicitly supplied String for authored scene references. Before this change, fake items were only rendered in previews and production pages displayed static symbols from localized feature JSON. The existing screen/navigation implementation under Onboarding/Legacy now hosts animated OnboardingPage content.

The module targets Swift 6.2, iOS/iPadOS 17, and macOS 14. No shared tree or real document operation is needed for these flat, explicitly authored display states.

## Goals / Non-Goals

**Goals:**

- Make `Wait` and `Change` the complete vocabulary of timeline operations.
- Separate finite scenario preparation from cancellable playback and SwiftUI rendering.
- Preserve identity and deterministic replay for each prepared scenario.
- Make timing and lifecycle behavior testable without real elapsed-time sleeps.

**Non-Goals:**

- A general animation framework, remote/JSON scenario format, interactive branching, arbitrary seeking, or animation of every possible property.
- Separate insert/remove/update operations, automatic tree operations, or a second item-property builder language.
- Spring completion semantics, a dedicated typewriter primitive, audio, pointer simulation, or nested parallel timelines.
- Changing navigation semantics, completion persistence, or the document model. The animation DSL and prepared snapshots remain internal to CorePresentation; the public feature initializer accepts a typed scenario selector.

## Decisions

### 1. Use a result builder with exactly two operation types

Introduce `OnboardingScenario`, `OnboardingScenarioBuilder`, `Wait`, and `Change`. The builder normalizes its expressions to an ordered internal step description. The builder supports straight-line composition, ordinary for loops, optional groups, and reusable groups returning operation arrays. These flatten to the same two operation types; no additional animation primitives are introduced.

`Wait` accepts a `Duration`. `Change` accepts a `Duration` and a synchronous `(inout [OnboardingItem]) -> Void` transformation. Use the standard ease-in-out curve for all transitions; no curve type, stored curve, or authoring parameter is needed. All nonempty scenarios repeat until task cancellation; pauses between iterations are ordinary trailing `Wait` operations. Durations are explicit, including `.zero`; the presentation uses `.easeInOut(duration:)`.

Illustrative authoring shape:

```swift
let task = OnboardingItemBuilder(title: "Write release notes").build()
let replacement = OnboardingItemBuilder(title: "Test the update").build()

let scenario = OnboardingScenario(initial: [task]) {
	Wait(.milliseconds(600))

	Change(duration: .milliseconds(250)) { items in
		items[0].isSelected = true
	}

	Wait(.milliseconds(450))

	Change(duration: .milliseconds(300)) { items in
		items[0].title.strikethrough = true
		items[0].isSelected = false
	}

	Wait(.milliseconds(600))

	Change(duration: .milliseconds(250)) { items in
		items.removeAll { $0.id == task.id }
		items.append(replacement)
	}

	Wait(.seconds(1))
}
```

The index is safe for the known single-item states preceding removal in this example. Larger scenes can use ordinary identity-based collection lookup; a new collection wrapper is unnecessary for the initial mechanism. Authors are responsible for valid indexing and side-effect-free transformations.

**Alternative:** Four operations (`wait`, `update`, `insert`, `remove`) or key-path setters. These increase the vocabulary and require additional grouping for simultaneous structural edits. The two-operation choice follows the agreed authoring model and allows a complete collection change in one block.

### 2. Prepare immutable target states once

Scenario construction performs validation and preparation synchronously, on the main actor where needed by existing onboarding factories:

1. Validate nonnegative durations and unique initial item IDs.
2. Copy the current item collection for each `Change`, execute its transformation once, and validate the resulting IDs.
3. Record an internal wait or a change carrying its target snapshot and duration.
4. Retain the initial and final snapshots and assign a stable scenario-instance identity for view replacement.
5. Reject a nonempty scenario with no positive step duration. Empty sequences remain static.

Use a nonthrowing preparation initializer. Invalid data triggers assertionFailure with a descriptive reason and the zero-based step index when applicable. No PreparationError or recoverable error API is exposed. Validate declarative durations before evaluating transformations. With assertions disabled, invalid input returns an empty static scenario and discards all partially prepared states, so no invalid or zero-time loop can run. Transformations must not read changing external state or perform side effects; the API cannot enforce purity.

Prepared scenarios contain no transformation closures. Looping, reactivation, and SwiftUI redraws reuse snapshots. Build items once in a scenario factory, and retain that prepared scenario for the scene lifetime rather than reconstructing it in `body`.

**Alternative:** Execute transformations during playback. This can repeat side effects and generate fresh IDs on every loop, and makes final-state inspection depend on running the entire timeline. Snapshot preparation avoids those issues at the cost of memory proportional to scene size and change count.

### 3. Treat hierarchy as explicit display data

Continue using `[OnboardingItem]`; do not introduce `Hierarchy`, `CoreModule` tree operations, or parent IDs. `level` and `state` retain their existing presentation meaning. A collapse demonstration changes the parent's indicator and removes descendants together; expanding explicitly restores the desired rows and their original IDs.

Changing an existing ID means removal/insertion from the renderer's perspective. Preserve IDs for rows intended to persist through changes. Permit an empty collection and identical titles, but reject duplicate IDs within any one snapshot.

**Alternative:** Infer descendants from indentation or call real outline actions. This would introduce hidden structural behavior and document dependencies into a deliberately fake scene model.

### 4. Repeat the scenario in the owning task

`OnboardingPlayer` retains one immutable prepared scenario, current items, and an injectable monotonic sleeper. Its single `run()` method resets to the initial state, iterates through the prepared steps, and repeats indefinitely. It has no playback mode, completion/running flags, request tracking, generation counter, or start/stop API.

Publish a change at step start and wait for its duration. A wait only suspends. Zero-duration changes apply without animation and do not sleep; positive-duration no-op changes still consume their duration. Use ordinary trailing waits to hold the final state. After the last duration, reset without animation and repeat. An empty scenario returns immediately. Preparation rejects nonempty zero-time scenarios, so every active cycle suspends.

Check task cancellation before every step, even if an injected sleeper ignores cancellation. After the final step, the outer loop condition checks cancellation before resetting the scenario; a separate check after each suspension is redundant. The caller owns exactly one run task and cancels it before restarting. No internal task or separate run identifier is needed: cancelled tasks cannot publish again after resuming. Keep sleeper injection for deterministic tests.

The timeline uses declared durations rather than animation completion callbacks. Scheduler delays can make a step last longer, but never authorize an early next step. The fixed curve is `.easeInOut`; spring settling and overlapping timelines remain outside this change.

**Alternative:** A player state machine with once/loop policies, activation requests, and run generations. The required behavior is continuous replay, so SwiftUI task ownership and cooperative cancellation provide the needed lifecycle without that additional state.

### 5. Let SwiftUI own presentation lifetime

`OnboardingSceneView` accepts a prepared scenario and explicit `isActive`. It wraps a private scene content view keyed by scenario identity using `.id(scenario.id)`. Each content instance owns its own player, so replacing the scenario also replaces its state and cancels the old view task. Independent windows receive independent players even for the same scenario.

Preserve the existing `List` container and render `OnboardingItemView` rows with stable item IDs and authored order/indentation. Apply each target snapshot in one transaction. Reset and zero-duration updates disable inherited animations. Discrete text/property changes do not imply custom interpolation.

The content uses `.task(id: isActive && scenePhase == .active && !reduceMotion)`. It calls `run()` only when that condition is true. SwiftUI cancels the task when the condition changes or the content disappears. Reactivation starts a new run that resets to the prepared initial state. A cancelled task checks cancellation before any later publication; an already committed visual transition need not reverse.

For Reduce Motion, render `scenario.final` directly and disable animation in the view transaction. No player mode, final-state publication, or timer is needed. When the setting is disabled, the active view starts the run again. The read-only environment is respected; its preview renders an equivalent static final-state scenario.

**Alternative:** Track visibility, activation requests, reduced-motion mode, and run generation in the player. These duplicate the lifecycle already provided by the view and its task.

### 6. Deliver three independent reference scenarios

Expose three retained scenario factories beside the existing fixture: makeSubitemsScenario, makeCustomizationScenario, and makeMirrorsScenario. Each returns its own prepared scenario identity and independently repeating timeline with an initial 800-millisecond wait and final two-second hold. Provide a separate animated preview for each, plus static-final and inactive previews. Preserve the existing scene view and player.

The subitems scenario starts with OnboardingItemsFactory.makeItems(). Projects and Today have no custom icons and use the neutral .point fallback. Insert a selected blank row under App Update, one indentation level deeper, and type "Prepare release checklist" one Swift Character at a time using zero-duration Change and 65-millisecond Wait operations. Hide its caret. Collapse App Update by updating its indicator and removing all its displayed descendants in one change. After a hold, expand it and restore the typed child and original descendants in their original order with their original identities, then clear selection. Derive the descendant range from the supplied fixture's contiguous indentation levels while preparing this reference; hierarchy remains explicit display data in the general mechanism.

The customization scenario defaults to the subitems scenario's final snapshot, without including or replaying its operations. Select Projects, set squareStack without changing its color, hold, and deselect. Then select Today, set calendar, then red, hold, and deselect. A shared helper accepts an optional color, omitting color operations for Projects. Finally select the checklist, apply strikethrough, disabled text color, and tertiary icon appearance, hold, and clear selection. No insertion, collapse, expansion, or typing occurs in this scenario. Root selection/icon/color/deselection changes use 150-millisecond transitions, with 250-millisecond intermediate waits and a 400-millisecond hold per root; Projects omits the color step.

The mirrors scenario uses the customization scenario's final snapshot as its base, without replaying its operations. Before constructing the prepared scenario, clear the source checklist's text and completed appearance, select it, and insert its selected mirror under Today with a distinct stable identity and linkPoint icon. Both blank rows show carets and are visible from the initial snapshot, including during the initial wait and after each loop reset. Type "Prepare release checklist for launch" into both rows in the same zero-duration Change per character. Keep both rows selected throughout. When typing finishes, hide both carets, wait 500 milliseconds, then apply strikethrough, disabled text color, and tertiary icon appearance to both in one change. Hold the completed pair for two seconds before repeating. No insertion or selection animation precedes typing. Unrelated rows and prior root customization remain unchanged. These are fake display snapshots updated together without a domain mirror model or document operation.

Use stable string constants in Onboarding/String+Onboarding.swift through extension String and build(id:) for Projects, App Update, Today, the inserted checklist, and its mirror. Resolve targets by identity, including with renamed or duplicated titles. All three factories accept explicit initial snapshots for composition and tests. Default preparation of preceding final snapshots happens synchronously, once during construction; it does not run preceding playback. Retain each prepared scenario for the scene lifetime. Scenario construction and factories remain nonthrowing. Preparation asserts on invalid durations or duplicate identities and returns an empty static fallback when assertions are disabled. The reference entry-point guards assert and return an empty scenario if the subitems parent or mirror source/destination is absent. The private identity lookup used inside authored transformations treats a missing target as a programmer error and traps; no recovery UI or throwing API is introduced. The preview retains a nonoptional scenario in state, derives staticFinalState without throwing, and supplies active scenePhase within previews only.

Do not route animations through document actions or analytics. Preserve existing screen/button analytics and completion persistence while migrating feature content and platform assembly actor boundaries.

### 7. Compose an onboarding page

Add internal OnboardingPage in CorePresentation/Onboarding. Accept title, subtitle, prepared scenario, and an isActive flag defaulting to true. On both platforms place the existing OnboardingSceneView above a centered title/subtitle block in a vertical stack. The animation takes the available height, while explanatory text retains its natural wrapped height. Use semantic title/body styling, secondary subtitle color, a heading accessibility trait for the title, and the existing decorative accessibility treatment for the animation. Keep the illustration content bounded to 420 points and the caption to 640 points, with padding inside each section. Hide the List content background, make row backgrounds clear, and omit any outer border or rounded card. Selection highlights remain authored row content.

On macOS use a window width range of 640–820 points with an ideal width of 680 points and a height range of 560–640 points with an ideal height of 600 points. Give the illustration section system textBackgroundColor across the window width. The centered caption and full-width footer inherit the same window material. OnboardingView stacks the page above its footer, with no horizontal columns or footer overlay. OnboardingPage does not accept a footer. There is no footer divider, zoom, automatic scrolling, or fixed horizontal illustration column. Page previews use the same material behind the caption and a 680 × 540-point frame.

Forward isActive directly to the existing scene; keep task ownership, cancellation, Reduce Motion, and independent playback there. Do not create scenarios in the page body. A retained preview wrapper prepares each scenario once and supplies active scenePhase only for preview hosting. Provide separate page previews for subitems, customization, and mirrors. OnboardingView uses this component for feature pages on both platforms. Remove the obsolete static PageView. Keep navigation/footer behavior and gate playback to the selected, incomplete page; inactive preloaded iOS tabs must not play.

### 8. Create animated features in Swift

Onboarding is a public namespace. Its nested public, main-actor-isolated Onboarding.Feature type lives in Onboarding+Feature.swift and stores title, subtitle, and one prepared OnboardingScenario alongside its stable feature ID. Its public main-actor initializer accepts Onboarding.Feature.Scenario (subitems, customization, mirrors), resolves it to the concrete factory, and retains the prepared result. Do not rebuild scenarios in body or during navigation. Onboarding.Feature itself no longer conforms to Codable because prepared snapshots are runtime presentation data.

OnboardingFactory.build() is the shared Swift definition of all three introduction pages, ordered subitems/customization/mirrors. It takes no version arguments and always creates the complete Onboarding.Feature array with the ordered IDs structured_lists_intro, customize_items_intro, and mirrors_intro, localized text, and concrete scenario selectors. Onboarding.Feature.Scenario is an ordinary Swift enum without serialization. Assemblies and screen/footer previews use this same factory. Onboarding.Feature has no minVersion, maxVersion, or showsOnFirstLaunch properties.

The platform coordinators own the only version decision: show onboarding if no valid saved onboarding version exists, or if the current application version is strictly greater than the saved version. Equal or older app versions do not show it. When eligible, show the entire current factory output. Completing or skipping onboarding records the current version through the existing platform callbacks. Missing current app version prevents presentation.

Remove all platform/test onboarding.json files and their decoding types. Move the six English/Russian page strings into OnboardingLocalizable.xcstrings and access them through OnboardingLocalization and Bundle.module. This catalog localizes text only; page order, IDs, and scenarios are authored in Swift. Remove the unused test resource declaration from Package.swift. Preserve button navigation, Skip/Get Started, macOS Back, the saved-version presentation gate, and existing privacy-safe analytics. On iOS activate only the selected page; on completion deactivate playback. AppKit-hosted NSHostingController content does not automatically receive an active SwiftUI scenePhase. Wrap the macOS onboarding root in a private view that seeds activity from NSApplication.isActive, refreshes it on appearance, and observes didBecomeActive/didResignActive notifications. Inject the corresponding active/inactive scenePhase into the root so the shared task gate starts and cancels playback correctly in the modal AppKit window. Do not force the phase permanently active or change the shared player. On macOS replacing the selected feature continues to key page identity and cancel the old scene task. Respect safe areas when combining the page with the existing footer.

### 9. Verify state, timing, and lifecycle separately

Use Swift Testing and an injected controllable sleeper to verify ordered snapshots, no early advancement, atomic collection changes, once-only preparation, looping, empty/zero-duration cases, validation, replacement, cancellation, and independent players. Verify cancellation during both waits and changes, multiple iterations, stable IDs, restart after cancellation, and independent players. Presentation lifecycle is owned by SwiftUI task cancellation; reduced motion renders the prepared final snapshot directly.

Follow AAA structure, group test cases by functionality in labeled extensions, and keep test actions/stubs in `// MARK: - Nested data structs` extensions. Use tabs and dedicated labeled protocol-conformance and private-method extensions, including separate SwiftUI `View` conformance.

Build the package for macOS and an iOS Simulator destination using existing project tooling, run the focused onboarding tests plus existing onboarding regressions, and inspect the reference scene on iPhone, iPad, and Mac. Check structural transitions and Reduce Motion visually; snapshot logic tests alone cannot prove those visuals.

## Risks / Trade-offs

- [Snapshots consume memory proportional to rows and changes] → Keep onboarding scenes small and finite; store one target snapshot per change rather than one per frame.
- [Arbitrary Swift transformations can trap or capture external mutable state] → Document pure, synchronous authoring and validate the produced snapshots. No sandboxing or purity enforcement is promised.
- [A static final state can be empty or unhelpful] → Authors must choose an informative final state for the reference and future production scenes; selectable static checkpoints are deferred.
- [Some view properties cannot interpolate] → Promise a correct target state and one transaction, with visual inspection for supported effects rather than universal smooth interpolation.
- [SwiftUI reconstructs or preloads views] → Retain prepared scenario identity, use explicit activation, and key scene content by scenario identity and give each presentation its own player and view task.
- [A reset can appear abrupt] → Hold the final state with a trailing `Wait`; authors can explicitly script a return before the final pause when desired.

## Migration Plan

Keep the Swift feature factory, shared string catalog, page rendering, previews, and platform call sites coherent. Verify focused regressions and both complete applications, then inspect the composed screen with its footer. No persisted settings or document migration is required; existing onboarding-version keys and completion callbacks remain applicable. A rollback must restore factory call sites and their former resource-loading contract together.

### Illustration layout

Use the List's natural top-aligned layout with original semantic fonts, icon sizes, and spacing. Do not add zoom, focus state, programmatic scrolling, or centering spacer rows. Selection and typing remain authored item appearance; they do not reposition the illustration viewport.

### Initial item factory

OnboardingItemsFactory.makeItems() owns construction of the initial fake item collection. Scenario defaults, row previews, and fixture-based tests use this factory directly. The Onboarding namespace retains scenario factories; the onboarding String extension owns shared named item IDs. Preserve the existing contents, order, hierarchy, named identities, and builder-generated IDs when extracting this construction.

## Implementation baseline

This design describes the final implementation in commit `3855b822654a2fda54499a0410b431acca431a0a`. The horizontal-window, overlay-footer, automatic-focus, UUID-item-ID, and JSON/version-filtering experiments from the implementation session are superseded. Keep scenario-instance UUIDs distinct from String item identities. The persisted `onboarding_version` key and document format are unchanged.
