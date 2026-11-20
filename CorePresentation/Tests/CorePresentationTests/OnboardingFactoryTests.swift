import Testing
@testable import CorePresentation

@MainActor struct OnboardingFactoryTests { }

// MARK: - Animated feature preparation
extension OnboardingFactoryTests {

	@Test func build_createsThreeFeaturesWithTheirSpecificScenarios() throws {
		// Arrange
		let expectedIDs = ["structured_lists_intro", "customize_items_intro", "mirrors_intro"]

		// Act
		let result = OnboardingFactory.build()

		// Assert
		#expect(result.map(\.id) == expectedIDs)
		#expect(result.map(\.title) == [OnboardingLocalization.subitemsTitle, OnboardingLocalization.customizationTitle, OnboardingLocalization.mirrorsTitle])
		#expect(result.allSatisfy { !$0.subtitle.isEmpty && !$0.scenario.steps.isEmpty })
		#expect(Set(result.map(\.scenario.id)).count == 3)
		let subitems = try #require(result.first).scenario
		let customization = try #require(result.dropFirst().first).scenario
		let mirrors = try #require(result.last).scenario
		#expect(subitems.initial.count == 12)
		#expect(subitems.final.count == 13)
		#expect(customization.initial.count == 13)
		#expect(customization.final.first { $0.id == String.projects }?.icon.name == .squareStack)
		#expect(customization.final.first { $0.id == String.today }?.icon == .init(name: .calendar, token: .red))
		#expect(customization.final.first { $0.id == String.releaseChecklist }?.title.strikethrough == true)
		#expect(mirrors.initial.filter(\.isSelected).map(\.id) == [String.releaseChecklist, String.releaseChecklistMirror])
		#expect(mirrors.final.first { $0.id == String.releaseChecklistMirror }?.title.value == "Prepare release checklist for launch")
	}

	@Test func feature_keepsContentAndPreparedScenarioOnCopy() {
		// Arrange
		let feature = Onboarding.Feature(
			id: "mirrors_update",
			title: "Mirrors",
			subtitle: "Shared content",
			scenario: .mirrors
		)

		// Act
		let copy = feature

		// Assert
		#expect(copy.id == "mirrors_update")
		#expect(copy.title == "Mirrors")
		#expect(copy.subtitle == "Shared content")
		#expect(copy.scenario.id == feature.scenario.id)
		#expect(copy.scenario.steps == feature.scenario.steps)
	}

}
