## Purpose

Defines how onboarding authors describe and present timed demonstrations of fake outline items using two declarative operations, with predictable playback across iOS, iPadOS, and macOS.

## ADDED Requirements

### Requirement: Two-operation scenario authoring
The mechanism SHALL accept an initial ordered collection of fake onboarding items and a finite ordered sequence containing only `Wait` and `Change` operations. A `Change` SHALL allow authors to transform the entire item collection, including updating properties, inserting, removing, and reordering items, without separate operation types for those actions.

#### Scenario: Describe a list demonstration
- **WHEN** an author defines initial items followed by a wait, a property change, and a collection change
- **THEN** the scenario accepts that description using only the two supported operation types
- **AND THEN** the operations preserve their declared order

#### Scenario: Change several items together
- **WHEN** a single change updates one item's selection, removes another item, and inserts a third item
- **THEN** all resulting differences belong to one target state and one transition
- **AND THEN** no intermediate partially modified collection is presented

### Requirement: Prepared state and stable identity
Preparing a scenario SHALL evaluate each change transformation exactly once in declaration order, using the preceding state as its input. Playback, replay, looping, and redraws of the same prepared scenario SHALL reuse the resulting states without evaluating transformations again. Retained items SHALL be matched across states by their identities, independently of their titles or positions.

#### Scenario: Compose dependent changes
- **WHEN** one change inserts an item and a later change updates that item
- **THEN** the later change receives the state containing the inserted item

#### Scenario: Replay a prepared scenario
- **WHEN** a prepared scenario is replayed or begins another loop
- **THEN** its transformations are not evaluated again
- **AND THEN** the original initial state and all prepared item identities are reused

#### Scenario: Distinguish identical titles
- **WHEN** two items have the same title and different identities, and their order changes
- **THEN** both remain distinct items throughout the transition

### Requirement: String item identities and shared fixtures
Onboarding items SHALL use String identities. The shared initial-item factory SHALL supply the existing fake list. Named String constants SHALL identify Projects, App Update, Today, the inserted release checklist, and its mirror. Explicit builder identities SHALL be preserved; independently built rows without explicit identities SHALL receive fresh UUID strings. Prepared scenario-instance identity SHALL remain separate from item identity.

#### Scenario: Recreate the initial list
- **WHEN** the initial-item factory is called more than once
- **THEN** named reference rows retain the same String identities and authored hierarchy
- **AND THEN** other independently built rows receive fresh identities

#### Scenario: Preserve an explicit item identity
- **WHEN** an author builds a row with an explicit String identity
- **THEN** the row retains that identity for use in later collection transformations

### Requirement: Ordered timing and transitions
A wait SHALL preserve the current state for its specified duration. A change SHALL publish its complete target state at the start of its step and request one visual transition with the specified duration and a standard ease-in-out curve. The next operation SHALL NOT start before the current step's duration has elapsed. All animated changes SHALL use the same ease-in-out curve; the authoring API SHALL NOT expose curve configuration. A zero-duration change SHALL apply immediately without animation. Properties without visual interpolation SHALL still reach their target values.

#### Scenario: Hold an intermediate state
- **WHEN** a selection change is followed by a 600-millisecond wait
- **THEN** the selected state remains unchanged throughout that wait
- **AND THEN** the following operation does not start before the wait has elapsed

#### Scenario: Account for change duration
- **WHEN** a 250-millisecond change is immediately followed by another operation
- **THEN** the first change requests a 250-millisecond transition
- **AND THEN** the following operation does not start before those 250 milliseconds have elapsed

#### Scenario: Apply a change immediately
- **WHEN** a change has zero duration
- **THEN** its complete target state is applied without animation
- **AND THEN** it does not introduce a playback delay

#### Scenario: Keep duration for an unchanged target
- **WHEN** a change produces the same item state as its input and has a positive duration
- **THEN** its duration still elapses before the next step

### Requirement: Continuous loop behavior
Playback SHALL repeat a nonempty scenario continuously until its presentation task is cancelled. After the final step's duration, playback SHALL restore the original initial state without animation and begin the first operation again. A pause between iterations SHALL be expressed by an ordinary trailing wait; there SHALL be no separate playback policy or loop-pause setting. An empty sequence SHALL display its initial state without scheduling repeated work. A nonempty scenario with no positive step duration SHALL be rejected before playback.

#### Scenario: Repeat a scene continuously
- **WHEN** the final step's duration elapses in an active scene
- **THEN** the original initial state is restored without an animated reverse transition
- **AND THEN** the first declared operation begins again without a separate restart request

#### Scenario: Hold the final state before restarting
- **WHEN** a scenario ends with a two-second wait
- **THEN** the final state remains visible throughout that wait
- **AND THEN** the next iteration begins only after the wait has elapsed

#### Scenario: Present an empty sequence
- **WHEN** an empty sequence is activated
- **THEN** the initial state remains visible
- **AND THEN** no loop or delay is scheduled

### Requirement: Scenario validation
Scenario preparation SHALL reject negative step durations and duplicate item identities in the initial state or any target state. Invalid authored data SHALL trigger a developer assertion identifying the reason and, when applicable, the invalid step, without throwing a recoverable error or displaying error content to the user. When assertions are disabled, preparation SHALL return an empty static scenario. Invalid scenarios SHALL NOT start playback or publish partially prepared states. Empty item collections SHALL be supported.

#### Scenario: Reject an invalid duration
- **WHEN** a scenario contains a wait or change with a negative duration
- **THEN** a developer assertion identifies the negative duration and its step

#### Scenario: Reject duplicate identities
- **WHEN** the initial collection or any change result contains two items with the same identity
- **THEN** a developer assertion identifies duplicate identities and the affected state or step

#### Scenario: Reject a loop without elapsed time
- **WHEN** a nonempty scenario has only zero-duration steps
- **THEN** a developer assertion identifies the missing positive-duration step

#### Scenario: Remove every item
- **WHEN** a valid change removes the last remaining item
- **THEN** its empty target state is accepted and displayed

### Requirement: Activation and cancellation
A scene SHALL advance only while its presentation is visible, explicitly active, and its application scene is active. Disappearance, deactivation, replacement of the scenario, or application inactivity SHALL cancel pending playback and prevent obsolete work from publishing later states. Reactivation SHALL start from the prepared initial state. Multiple presentations SHALL maintain independent playback state.

#### Scenario: Keep a preloaded page inactive
- **WHEN** an unselected onboarding page is created alongside the selected page on iOS or iPadOS
- **THEN** its scene does not advance until explicitly activated

#### Scenario: Deactivate during a delay
- **WHEN** a scene becomes inactive during a wait or transition duration
- **THEN** pending playback stops
- **AND THEN** the cancelled run cannot publish a later target state
- **AND THEN** the next activation starts from the initial state

#### Scenario: Replace a running scenario
- **WHEN** a presentation receives a different prepared scenario while a previous run is pending
- **THEN** the previous run cannot overwrite the new scenario's state
- **AND THEN** the new scenario starts from its own initial state when active

#### Scenario: Run independent presentations
- **WHEN** two windows or scene presentations display the same prepared scenario
- **THEN** advancing or cancelling one presentation does not change the other's playback state

### Requirement: Reduced-motion presentation
When Reduce Motion is enabled, a scene SHALL cancel timed playback and display the prepared final state without animated transitions or repeated work. For a scenario with no changes, the final state SHALL equal its initial state. Disabling Reduce Motion SHALL restart normal playback from the initial state when the presentation is active.

#### Scenario: Enable reduced motion during playback
- **WHEN** Reduce Motion becomes enabled during a running scenario
- **THEN** the scene stops playback and immediately displays its final state without animation
- **AND THEN** no pending step or loop later changes that state

#### Scenario: Disable reduced motion
- **WHEN** Reduce Motion becomes disabled for an active presentation
- **THEN** playback restarts from the prepared initial state

### Requirement: Explicit fake hierarchy and rendering
The scene SHALL display the authored collection order and each item's configured appearance and indentation on iOS, iPadOS, and macOS. Hierarchy indicators and indentation SHALL be presentation data: changing a parent's expansion indicator alone SHALL NOT implicitly insert or remove descendants. Authors SHALL express changes to descendant visibility in the same collection transformation when needed. The mechanism SHALL provide a reference scene demonstrating waits, property updates, and structural collection changes.

#### Scenario: Collapse a fake parent and hide descendants
- **WHEN** one change sets a parent's indicator to collapsed and removes its displayed descendant rows
- **THEN** the parent remains visible and the descendants disappear in the same transition
- **AND THEN** unrelated rows retain their order and configured indentation

#### Scenario: Display an item without a custom icon
- **WHEN** an item's custom icon name is absent
- **THEN** the row displays the default point icon using the configured icon appearance

#### Scenario: Change only a hierarchy indicator
- **WHEN** a change updates a parent's expansion indicator without changing the collection
- **THEN** the other rows remain displayed as authored

#### Scenario: Preview the reference scene
- **WHEN** the reference scene is presented on a supported platform
- **THEN** it demonstrates the declared waits, property updates, and structural changes using the existing fake item appearance

### Requirement: Separate reference demonstrations
The reference examples SHALL provide three separately prepared scenarios for subitems, customization, and mirrors, each with its own identity, independently looping timeline, an initial 800-millisecond hold, and animated preview. The subitems scenario SHALL start with the existing fake list. Projects and Today SHALL initially have no custom icon or custom color and SHALL display neutral point icons. By default, customization SHALL start with the subitems scenario's final snapshot, and mirrors SHALL prepare its initially selected pair from customization's final snapshot. These starting snapshots SHALL NOT require playing or including preceding scenario operations. All actions SHALL use predefined identities rather than titles. Retained rows SHALL keep their identities. Subitems and customization SHALL select at most one row at a time; mirrors SHALL keep both linked rows selected throughout playback.

#### Scenario: Play one demonstration independently
- **WHEN** any reference scenario is presented
- **THEN** it plays only its own operations and holds its final state for two seconds
- **AND THEN** it resets to its own initial state and repeats independently of the other scenarios

#### Scenario: Rename demonstration titles
- **WHEN** demonstration item titles are renamed or duplicated while their predefined identities are preserved
- **THEN** insertion and root customization still target the same authored items
- **AND THEN** existing titles remain as supplied

#### Scenario: Insert and type a new subitem
- **WHEN** the initial hold finishes in the subitems scenario
- **THEN** an empty selected row is inserted immediately after App Update, indented one level deeper, with a visible caret
- **AND THEN** its title grows one complete character at a time, with a 65-millisecond wait after each character, until it reads "Prepare release checklist"
- **AND THEN** the row remains selected during typing and the caret disappears when typing finishes

#### Scenario: Collapse and expand subitems
- **WHEN** typing finishes in the subitems scenario
- **THEN** App Update becomes selected and collapsed, and all its visible descendants are removed in the same change
- **AND THEN** App Update expands and restores the typed checklist and original descendants in their original order with the same identities and indentation
- **AND THEN** selection is cleared, while unrelated rows and root appearance remain unchanged

#### Scenario: Customize items independently
- **WHEN** the customization scenario starts with the completed subitems snapshot
- **THEN** Projects becomes the only selected row and receives a stack icon without changing its icon color
- **AND THEN** Today remains unchanged until Projects customization finishes
- **AND THEN** selection moves to Today, which receives a calendar icon, followed by a red icon color
- **AND THEN** Projects retains its stack icon and original neutral color while Today is being customized
- **AND THEN** the inserted text and all existing rows remain present without resetting or changing identity
- **AND THEN** the typed checklist becomes selected and receives strikethrough, disabled text color, and a tertiary icon before selection is cleared

#### Scenario: Type and complete both mirror-linked rows
- **WHEN** the mirrors scenario is first displayed or resets for another iteration
- **THEN** the source checklist and its distinct mirror under Today are already visible and selected, with empty titles, primary appearance, no strikethrough, and carets in both rows
- **AND THEN** the mirror uses linkPoint and remains one indentation level below Today
- **AND THEN** typing builds "Prepare release checklist for launch" one character at a time in both rows within each change
- **AND THEN** both carets disappear after typing finishes, followed by a 500-millisecond hold before both titles are struck through in one change
- **AND THEN** both rows receive disabled text color and tertiary icon appearance and remain selected during the final hold
- **AND THEN** row identities, order, and all unrelated row states remain unchanged throughout the timeline

### Requirement: Onboarding page composition
The mechanism SHALL provide an internal OnboardingPage accepting a prepared scenario, title, subtitle, and explicit activation. On both platforms it SHALL display the animation above a centered, wrapping title and subtitle. Both platforms SHALL use the existing scene's playback and Reduce Motion behavior. It SHALL provide separate page previews for the three reference scenarios while preserving existing navigation behavior.

#### Scenario: Present a page with animation and explanatory text
- **WHEN** a page receives a prepared scenario, title, and subtitle
- **THEN** the animation appears above both text values on iOS and macOS
- **AND THEN** the title is exposed as an accessibility heading while decorative rows remain hidden from accessibility
- **AND THEN** text wraps at the available width and keeps its natural height
- **AND THEN** the illustration has no enclosing card or border and the list rows use transparent backgrounds

#### Scenario: Separate the illustration from macOS text and controls by color
- **WHEN** the macOS onboarding screen is presented in light or dark appearance
- **THEN** only the illustration area uses the adaptive system text background color
- **AND THEN** the title, subtitle, and footer share the same window-material background
- **AND THEN** the color separation spans the page width without a separate border or rounded panel around the illustration

#### Scenario: Control page animation
- **WHEN** the page's activation flag changes or Reduce Motion becomes enabled
- **THEN** the embedded scene uses its existing cancellation, restart, or static-final behavior
- **AND THEN** the page retains its title and subtitle

### Requirement: Animated production features
The public main-actor Onboarding.Feature type SHALL be nested in the Onboarding namespace. Its typed scenario selector SHALL resolve to one concrete prepared scenario retained together with the feature title and subtitle; the type SHALL NOT require serialization conformance. The shared Swift factory SHALL directly create subitems, customization, and mirrors features in that order. It SHALL always return the complete nonoptional array without version parameters, per-feature version limits, or file loading, decoding, throwing, or Bundle arguments. Page strings SHALL be localized through the shared English/Russian string catalog. No onboarding JSON definition SHALL be required on either platform.

#### Scenario: Load the introductory pages
- **WHEN** the onboarding factory is called for first launch
- **THEN** it creates subitems, customization, and mirrors features with their localized titles and subtitles
- **AND THEN** each feature retains the selected concrete prepared scenario for its lifetime

#### Scenario: Build without external definitions
- **WHEN** either platform requests its introductory features
- **THEN** the shared Swift factory provides their definitions without reading an onboarding JSON file
- **AND THEN** platform assemblies and screen/footer previews use the same page definitions

#### Scenario: Show onboarding for first launch or an upgrade
- **WHEN** a valid current app version exists and the saved onboarding version is absent or lower
- **THEN** the platform coordinator presents all current onboarding pages
- **AND THEN** individual features require no minimum/maximum version metadata

#### Scenario: Skip an already shown or older version
- **WHEN** the current app version is equal to or lower than the saved onboarding version
- **THEN** onboarding is not presented

#### Scenario: Skip presentation when the app version is unavailable
- **WHEN** no valid current app version exists
- **THEN** onboarding is not presented

#### Scenario: Retain prepared feature data
- **WHEN** a feature is copied or the user returns to its page
- **THEN** its prepared scenario identity and timeline are preserved without rebuilding the scenario

#### Scenario: Navigate animated pages
- **WHEN** the selected page changes through swipe, Next, or Back
- **THEN** OnboardingPage displays that feature's title, subtitle, and scenario
- **AND THEN** only the selected incomplete page may play
- **AND THEN** returning to a page reuses the same prepared scenario and restarts its playback through the existing scene lifecycle

#### Scenario: Complete or skip onboarding
- **WHEN** Get Started or Skip completes onboarding
- **THEN** playback is deactivated and the existing platform completion callback records the current onboarding version
- **AND THEN** existing screen/button analytics retain their event names and privacy-safe payloads

### Requirement: AppKit hosting activity bridge
The macOS onboarding root hosted in NSHostingController SHALL receive SwiftUI scene activity derived from the AppKit application's actual activity. Initial appearance and application activation/deactivation SHALL update the environment so the shared animation task can run, cancel, and restart in a modal AppKit window.

#### Scenario: Open macOS onboarding in an active application
- **WHEN** AppKit presents the onboarding window while the application is active
- **THEN** the selected scenario begins playback even when the hosting controller's default scenePhase is background

#### Scenario: Deactivate and reactivate the macOS application
- **WHEN** the application resigns active status during playback
- **THEN** the scene task is cancelled and no subsequent step is published
- **WHEN** the application becomes active again
- **THEN** the selected scenario restarts from its prepared initial state

### Requirement: Isolation from documents and user actions
Scene playback SHALL use fake in-memory data and SHALL NOT modify documents, persist scenario progress, register undo operations, invoke real copy/paste or drag-and-drop actions, or report simulated actions as user-action analytics. Existing onboarding feature selection, navigation, completion, and version persistence SHALL remain compatible.

#### Scenario: Play an editing demonstration
- **WHEN** a scenario simulates insertion, removal, reordering, or completion of fake items
- **THEN** no user document or undo history changes
- **AND THEN** no simulated button, menu, toggle, or drag-and-drop analytics events are emitted

#### Scenario: Use existing onboarding flows
- **WHEN** the existing feature-based onboarding is presented after the mechanism is added
- **THEN** animated title/subtitle/scenario pages replace static icon pages
- **AND THEN** navigation, completion callbacks, and persisted version behavior remain compatible

### Requirement: Natural illustration layout
The illustration SHALL use the List's natural top-aligned layout and original row typography, icons, and spacing. Selection and typing SHALL NOT trigger zoom or automatic scrolling. No centering spacer rows SHALL be inserted around authored items.

#### Scenario: Edit or select an item
- **WHEN** a scenario selects or types into a row
- **THEN** only the authored item changes occur, without moving the list viewport to center that row

#### Scenario: Display linked mirror rows
- **WHEN** both mirror-linked rows are selected
- **THEN** they retain their authored order and original sizing without automatic range centering

### Requirement: Vertical macOS onboarding page
On macOS the onboarding page SHALL arrange its animation above a centered title/subtitle block. Navigation SHALL appear in a full-width footer below the page. The illustration SHALL retain its distinct adaptive background with content bounded to 420 points; the centered caption SHALL be bounded to 640 points and SHALL share its background with the footer. No divider or footer overlay SHALL be added. The window SHALL use an ideal size of 680 × 600 points with resize bounds of 640–820 points wide and 560–640 points high.

#### Scenario: Present a macOS feature
- **WHEN** a feature page appears in macOS onboarding
- **THEN** its animation appears above the centered, wrapping title and subtitle
- **AND THEN** navigation spans the full window width below the page without overlapping the illustration or explanatory text
