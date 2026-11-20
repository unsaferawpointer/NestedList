import Foundation
import Testing
@testable import CorePresentation

@MainActor struct OnboardingScenarioTests { }

// MARK: - Preparation
extension OnboardingScenarioTests {

	@Test func preparation_composesChangesOnceAndPreservesSnapshots() {
		// Arrange
		let first = item("Same")
		let second = item("Same")
		let inserted = item("Inserted")
		var evaluations = 0

		// Act
		let sut = OnboardingScenario(initial: [first, second]) {
			Wait(.seconds(1))
			Change(duration: .milliseconds(250)) { items in
				evaluations += 1
				items[0].isSelected = true
				items.removeLast()
				items.insert(inserted, at: 0)
			}
			Change(duration: .zero) { items in
				evaluations += 1
				items[0].title.strikethrough = true
				items.reverse()
			}
		}

		// Assert
		#expect(evaluations == 2)
		#expect(sut.initial == [first, second])
		#expect(sut.steps[0] == .wait(.seconds(1)))
		guard case let .change(intermediate, transition) = sut.steps[1] else {
			Issue.record("Expected a prepared change")
			return
		}
		#expect(intermediate.map(\.id) == [inserted.id, first.id])
		#expect(intermediate[1].isSelected)
		#expect(!intermediate[0].title.strikethrough)
		#expect(transition == .init(duration: .milliseconds(250)))
		#expect(sut.final.map(\.id) == [first.id, inserted.id])
		#expect(sut.final[1].title.strikethrough)
		#expect(sut.steps.last == .change(sut.final, .init(duration: .zero)))
	}

	@Test func reordering_matchesDuplicateTitlesByIdentity() {
		// Arrange
		let first = item("Same")
		let second = item("Same")

		// Act
		let sut = OnboardingScenario(initial: [first, second]) {
			Change(duration: .seconds(1)) { $0.reverse() }
		}

		// Assert
		#expect(sut.final.map(\.id) == [second.id, first.id])
		#expect(sut.initial.map(\.id) == [first.id, second.id])
	}

	@Test func hierarchy_changesOnlyWhatAuthorSpecifies() {
		// Arrange
		var parent = item("Parent")
		parent.state = .expanded
		var child = item("Child")
		child.level = 1
		let unrelated = item("Unrelated")

		// Act
		let sut = OnboardingScenario(initial: [parent, child, unrelated]) {
			Change(duration: .seconds(1)) { $0[0].state = .collapsed }
			Change(duration: .seconds(1)) { $0.remove(at: 1) }
		}

		// Assert
		guard case let .change(intermediate, _) = sut.steps[0] else {
			Issue.record("Expected a prepared change")
			return
		}
		#expect(intermediate.map(\.id) == [parent.id, child.id, unrelated.id])
		#expect(intermediate[1].level == 1)
		#expect(sut.final.map(\.id) == [parent.id, unrelated.id])
		#expect(sut.final[0].state == .collapsed)
	}

	@Test func emptyCollectionsAndSequences_areValid() {
		// Arrange
		let initial = [item("Task")]

		// Act
		let empty = OnboardingScenario(initial: []) { }
		let removed = OnboardingScenario(initial: initial) {
			Change(duration: .zero) { $0.removeAll() }
			Wait(.seconds(1))
		}

		// Assert
		#expect(empty.steps.isEmpty)
		#expect(empty.final.isEmpty)
		#expect(removed.final.isEmpty)
		#expect(removed.initial == initial)
	}
}

#if DEBUG && os(macOS)
// MARK: - Validation assertions
extension OnboardingScenarioTests {

	@Test func negativeDurations_assertBeforeEvaluatingChanges() async {
		// Arrange
		let expectedMessage = "Negative onboarding duration at step 1"

		// Act
		let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
			_ = OnboardingScenario(initial: []) {
				Change(duration: .zero) { _ in
					fatalError("A transformation ran before duration validation")
				}
				Wait(.seconds(-1))
			}
		}

		// Assert
		let diagnostic = String(decoding: result?.standardErrorContent ?? [], as: UTF8.self)
		#expect(diagnostic.contains(expectedMessage))
	}

	@Test func invalidLoopTiming_asserts() async {
		// Arrange
		let expectedMessage = "Onboarding scenario must contain a positive-duration step"

		// Act
		let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
			_ = OnboardingScenario(initial: []) {
				Wait(.zero)
				Change(duration: .zero) { _ in }
			}
		}

		// Assert
		let diagnostic = String(decoding: result?.standardErrorContent ?? [], as: UTF8.self)
		#expect(diagnostic.contains(expectedMessage))
	}

	@Test func duplicateIdentities_assertForInitialAndTargetStates() async {
		// Arrange
		let initialMessage = "Duplicate onboarding item IDs in initial state"
		let targetMessage = "Duplicate onboarding item IDs at step 1"

		// Act
		let initialResult = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
			let task = OnboardingItemBuilder(title: "Task").build()
			_ = OnboardingScenario(initial: [task, task]) { }
		}
		let targetResult = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
			let task = OnboardingItemBuilder(title: "Task").build()
			_ = OnboardingScenario(initial: [task]) {
				Wait(.seconds(1))
				Change(duration: .zero) { $0.append(task) }
			}
		}

		// Assert
		let initialDiagnostic = String(decoding: initialResult?.standardErrorContent ?? [], as: UTF8.self)
		let targetDiagnostic = String(decoding: targetResult?.standardErrorContent ?? [], as: UTF8.self)
		#expect(initialDiagnostic.contains(initialMessage))
		#expect(targetDiagnostic.contains(targetMessage))
	}
}
#elseif !DEBUG
// MARK: - Validation fallback
extension OnboardingScenarioTests {

	@Test func invalidPreparation_returnsEmptyStaticScenarioWithoutAssertions() {
		// Arrange
		let task = item("Task")
		var evaluations = 0

		// Act
		let negative = OnboardingScenario(initial: [task]) {
			Change(duration: .zero) { _ in evaluations += 1 }
			Wait(.seconds(-1))
		}
		let zeroTime = OnboardingScenario(initial: [task]) {
			Wait(.zero)
		}
		let duplicateInitial = OnboardingScenario(initial: [task, task]) { }
		let duplicateTarget = OnboardingScenario(initial: [task]) {
			Wait(.seconds(1))
			Change(duration: .zero) { $0.append(task) }
		}

		// Assert
		#expect(evaluations == 0)
		for scenario in [negative, zeroTime, duplicateInitial, duplicateTarget] {
			#expect(scenario.initial.isEmpty)
			#expect(scenario.final.isEmpty)
			#expect(scenario.steps.isEmpty)
		}
	}
}
#endif

// MARK: - Reference scenarios
extension OnboardingScenarioTests {

	@Test func scenarios_preserveContinuityWithIndependentTimelines() {
		// Arrange
		let fixture = OnboardingItemsFactory.makeItems()

		// Act
		let subitems = Onboarding.makeSubitemsScenario(initial: fixture)
		let customization = Onboarding.makeCustomizationScenario(initial: subitems.final)
		let mirrors = Onboarding.makeMirrorsScenario(initial: customization.final)

		// Assert
		#expect(subitems.initial == fixture)
		#expect(customization.initial == subitems.final)
		#expect(mirrors.initial.map(\.id).filter { $0 != String.releaseChecklistMirror } == customization.final.map(\.id))
		#expect(Set([subitems.id, customization.id, mirrors.id]).count == 3)
		#expect([subitems, customization, mirrors].allSatisfy { !$0.steps.isEmpty })
		#expect(subitems.final.count == fixture.count + 1)
		#expect(customization.final.map(\.id) == customization.initial.map(\.id))
		#expect(mirrors.final.count == mirrors.initial.count)
		for scenario in [subitems, customization, mirrors] {
			#expect(scenario.steps.last == .wait(.seconds(2)))
			#expect(scenario.final.allSatisfy { !$0.title.showsCaret })
		}
		for scenario in [subitems, customization] {
			#expect(scenario.final.allSatisfy { !$0.isSelected })
		}
	}

	@Test func fixture_preservesNamedIdentifiersAcrossCreations() {
		// Arrange
		let first = OnboardingItemsFactory.makeItems()
		let identifiers = [String.projects, String.appUpdate, String.today]

		// Act
		let second = OnboardingItemsFactory.makeItems()

		// Assert
		for id in identifiers {
			#expect(first.filter { $0.id == id }.count == 1)
			#expect(second.filter { $0.id == id }.count == 1)
			#expect(first.first { $0.id == id } == second.first { $0.id == id })
		}
	}

	@Test func scenarios_useIdentifiersWhenTitlesAreRenamedOrDuplicated() {
		// Arrange
		var fixture = OnboardingItemsFactory.makeItems()
		for index in fixture.indices {
			fixture[index].title.value = "Renamed item"
		}

		// Act
		let subitems = Onboarding.makeSubitemsScenario(initial: fixture)
		let customization = Onboarding.makeCustomizationScenario(initial: subitems.final)
		let mirrors = Onboarding.makeMirrorsScenario(initial: customization.final)

		// Assert
		#expect(subitems.initial == fixture)
		#expect(mirrors.final.first { $0.id == String.projects }?.icon == .init(name: .squareStack, token: .primary))
		#expect(mirrors.final.first { $0.id == String.today }?.icon == .init(name: .calendar, token: .red))
		#expect(mirrors.final.first { $0.id == String.releaseChecklist }?.title.value == "Prepare release checklist for launch")
		for original in fixture {
			#expect(mirrors.final.first { $0.id == original.id }?.title == original.title)
		}
	}
}

// MARK: - Subitems scenario
extension OnboardingScenarioTests {

	@Test func subitems_insertsSelectedSubitemAndTypesEveryCharacter() throws {
		// Arrange
		let sut = Onboarding.makeSubitemsScenario()
		let parent = try #require(sut.initial.first { $0.id == String.appUpdate })
		let text = "Prepare release checklist"

		// Act
		let states = changeStates(of: sut)
		let insertion = try #require(states.first)
		let newItem = try #require(insertion.first { $0.id == String.releaseChecklist })
		let typedItems = states.compactMap { state in
			state.first { $0.id == newItem.id && $0.title.showsCaret }
		}

		// Assert
		let parentIndex = try #require(insertion.firstIndex { $0.id == parent.id })
		#expect(insertion[parentIndex + 1].id == newItem.id)
		#expect(newItem.level == parent.level + 1)
		#expect(newItem.title.value.isEmpty)
		#expect(typedItems.allSatisfy { $0.isSelected })
		#expect(typedItems.map(\.title.value) == [""] + text.indices.map { String(text[...$0]) })
		#expect(sut.final.first { $0.id == newItem.id }?.title.value == text)
		#expect(sut.final.first { $0.id == newItem.id }?.title.strikethrough == false)
		for original in sut.initial {
			#expect(sut.final.first { $0.id == original.id } == original)
		}
	}

	@Test func subitems_collapsesAndRestoresAllDescendantsWithTheirIdentities() throws {
		// Arrange
		let sut = Onboarding.makeSubitemsScenario()
		let parentID = String.appUpdate
		let parentIndex = try #require(sut.initial.firstIndex { $0.id == parentID })
		let descendants = sut.initial.dropFirst(parentIndex + 1).prefix { $0.level > sut.initial[parentIndex].level }
		let hiddenIDs = Set(descendants.map(\.id) + [String.releaseChecklist])

		// Act
		let states = changeStates(of: sut)
		let collapseIndex = try #require(states.firstIndex { state in
			state.first { $0.id == parentID }?.state == .collapsed
		})
		let collapsed = states[collapseIndex]
		let restored = try #require(states.dropFirst(collapseIndex + 1).first)

		// Assert
		#expect(collapsed.allSatisfy { !hiddenIDs.contains($0.id) })
		#expect(collapsed.first { $0.id == parentID }?.isSelected == true)
		#expect(collapsed.map(\.id) == sut.initial.filter { !hiddenIDs.contains($0.id) }.map(\.id))
		#expect(restored == sut.final)
		#expect(restored.first { $0.id == parentID }?.state == .expanded)
		#expect(restored.filter { hiddenIDs.contains($0.id) }.map(\.id) == [String.releaseChecklist] + descendants.map(\.id))
		#expect(restored.first { $0.id == String.releaseChecklist }?.title.value == "Prepare release checklist")
		#expect(states.allSatisfy { $0.allSatisfy { $0.id != String.releaseChecklistMirror } })
	}
}

// MARK: - Customization scenario
extension OnboardingScenarioTests {

	@Test func customization_updatesProjectsThenTodayWithoutChangingHierarchy() throws {
		// Arrange
		let sut = Onboarding.makeCustomizationScenario()
		let projects = try #require(sut.initial.first { $0.id == String.projects })
		let today = try #require(sut.initial.first { $0.id == String.today })
		let customizedIDs = Set([projects.id, today.id, String.releaseChecklist])

		// Act
		let states = changeStates(of: sut)
		let projectsSelectionIndex = try #require(states.firstIndex { $0.contains { $0.id == projects.id && $0.isSelected } })
		let todaySelectionIndex = try #require(states.firstIndex { $0.contains { $0.id == today.id && $0.isSelected } })
		let projectsIconIndex = try #require(states.firstIndex { state in
			state.first { $0.id == projects.id }?.icon == .init(name: .squareStack, token: .primary)
		})
		let calendarIndex = try #require(states.firstIndex { state in
			state.first { $0.id == today.id }?.icon.name == .calendar
		})
		let redIndex = try #require(states.firstIndex { state in
			state.first { $0.id == today.id }?.icon == .init(name: .calendar, token: .red)
		})

		// Assert
		#expect(projects.icon == .init(name: nil, token: .primary))
		#expect(today.icon == .init(name: nil, token: .primary))
		#expect(projectsSelectionIndex < projectsIconIndex)
		#expect(projectsIconIndex < todaySelectionIndex)
		#expect(todaySelectionIndex < calendarIndex)
		#expect(calendarIndex < redIndex)
		#expect(states[projectsSelectionIndex].first { $0.id == today.id } == today)
		#expect(states[todaySelectionIndex].first { $0.id == projects.id }?.icon.name == .squareStack)
		#expect(states.allSatisfy { $0.filter(\.isSelected).count <= 1 })
		#expect(states.allSatisfy { $0.map(\.id) == sut.initial.map(\.id) })
		#expect(states.allSatisfy { $0.map(\.level) == sut.initial.map(\.level) })
		#expect(states.allSatisfy { $0.first { $0.id == projects.id }?.icon.appearence == projects.icon.appearence })
		for original in sut.initial where !customizedIDs.contains(original.id) {
			#expect(sut.final.first { $0.id == original.id } == original)
		}
	}

	@Test func customization_completesChecklistAfterSettingIconsAndColor() throws {
		// Arrange
		let sut = Onboarding.makeCustomizationScenario()

		// Act
		let states = changeStates(of: sut)
		let appearanceIndex = try #require(states.firstIndex { state in
			state.first { $0.id == String.today }?.icon == .init(name: .calendar, token: .red)
		})
		let completionIndex = try #require(states.firstIndex { state in
			state.contains { $0.id == String.releaseChecklist && $0.title.strikethrough }
		})
		let completed = try #require(sut.final.first { $0.id == String.releaseChecklist })

		// Assert
		#expect(appearanceIndex < completionIndex)
		#expect(completed.title.value == "Prepare release checklist")
		#expect(completed.title.strikethrough)
		#expect(completed.title.colorToken == .disabledText)
		#expect(completed.icon.appearence == .monochrome(token: .tertiary))
		#expect(states[completionIndex].first { $0.id == completed.id }?.isSelected == true)
		#expect(sut.final.allSatisfy { !$0.isSelected && !$0.title.showsCaret })
	}
}

// MARK: - Mirrors scenario
extension OnboardingScenarioTests {

	@Test func mirrors_startsWithBothRowsSelectedAndReadyForTyping() throws {
		// Arrange
		let fixture = Onboarding.makeCustomizationScenario().final
		let sourceID = String.releaseChecklist
		let mirrorID = String.releaseChecklistMirror

		// Act
		let sut = Onboarding.makeMirrorsScenario(initial: fixture)
		let original = try #require(sut.initial.first { $0.id == sourceID })
		let mirror = try #require(sut.initial.first { $0.id == mirrorID })
		let todayIndex = try #require(sut.initial.firstIndex { $0.id == String.today })

		// Assert
		#expect(Set(sut.initial.filter(\.isSelected).map(\.id)) == Set([sourceID, mirrorID]))
		#expect(original.title == mirror.title)
		#expect(original.title.value.isEmpty)
		#expect(original.title.showsCaret)
		#expect(!original.title.strikethrough)
		#expect(original.title.colorToken == .primary)
		#expect(original.icon.appearence == .monochrome(token: .primary))
		#expect(mirror.icon.name == .linkPoint)
		#expect(sut.initial[todayIndex + 1].id == mirrorID)
		#expect(mirror.level == sut.initial[todayIndex].level + 1)
		#expect(mirror.state == .leaf)
		#expect(!mirror.showsTrailingDisclosure)
		for row in fixture where row.id != sourceID {
			#expect(sut.initial.first { $0.id == row.id } == row)
		}
	}

	@Test func mirrors_typesInBothRowsThenStrikesThroughTogether() throws {
		// Arrange
		let sut = Onboarding.makeMirrorsScenario()
		let sourceID = String.releaseChecklist
		let mirrorID = String.releaseChecklistMirror
		let text = "Prepare release checklist for launch"

		// Act
		let states = changeStates(of: sut)
		let completionIndex = try #require(states.firstIndex { state in
			state.first { $0.id == sourceID }?.title.strikethrough == true
		})
		let typedValues = [sut.initial] + states.filter { state in
			state.first { $0.id == sourceID }?.title.showsCaret == true
		}
		let finishedTyping = states[completionIndex - 1]

		// Assert
		#expect(typedValues.compactMap { $0.first { $0.id == sourceID }?.title.value } == [""] + text.indices.map { String(text[...$0]) })
		#expect(finishedTyping.first { $0.id == sourceID }?.title.value == text)
		#expect(finishedTyping.first { $0.id == sourceID }?.title.showsCaret == false)
		#expect(finishedTyping.first { $0.id == sourceID }?.title.strikethrough == false)
		for state in [sut.initial] + states {
			let source = try #require(state.first { $0.id == sourceID })
			let mirror = try #require(state.first { $0.id == mirrorID })
			#expect(source.title == mirror.title)
			#expect(source.icon.appearence == mirror.icon.appearence)
			#expect(Set(state.filter(\.isSelected).map(\.id)) == Set([sourceID, mirrorID]))
			#expect(state.map(\.id) == sut.initial.map(\.id))
			for row in sut.initial where row.id != sourceID && row.id != mirrorID {
				#expect(state.first { $0.id == row.id } == row)
			}
		}
		for id in [sourceID, mirrorID] {
			let final = try #require(sut.final.first { $0.id == id })
			#expect(final.title.value == text)
			#expect(final.title.strikethrough)
			#expect(final.title.colorToken == .disabledText)
			#expect(final.icon.appearence == .monochrome(token: .tertiary))
			#expect(!final.title.showsCaret)
		}
	}
}

// MARK: - Nested data structs
private extension OnboardingScenarioTests {

	func item(_ title: String) -> OnboardingItem {
		OnboardingItemBuilder(title: title).build()
	}

	func changeStates(of scenario: OnboardingScenario) -> [[OnboardingItem]] {
		scenario.steps.compactMap { step in
			guard case let .change(items, _) = step else { return nil }
			return items
		}
	}
}
