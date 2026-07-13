//
//  ContentPresenterTests.swift
//  iOSTests
//
//  Created by Anton Cherkasov on 06.07.2026.
//

import Testing
import Foundation
import CoreModule
import CorePresentation
import DesignSystem
import Analytics
import Hierarchy
@testable import iOS

@MainActor
final class ContentPresenterTests {

	var sut: ContentPresenter!

	// MARK: - DI

	var interactor: ContentUnitInteractorMock!
	var router: ContentRouterMock!
	var settingsProvider: StateProviderMock<Settings>!
	var analytics: ContentAnalyticsServiceMock!
	var soundPlayer: SoundPlayerMock!

	init() {
		interactor = ContentUnitInteractorMock()
		router = ContentRouterMock()
		settingsProvider = StateProviderMock<Settings>()
		settingsProvider.stubs.state = Settings()
		analytics = ContentAnalyticsServiceMock()
		soundPlayer = SoundPlayerMock()
		sut = ContentPresenter(
			router: router,
			settingsProvider: settingsProvider,
			analytics: analytics,
			soundPlayer: soundPlayer
		)
		sut.interactor = interactor
	}

	deinit {
		sut = nil
		interactor = nil
		router = nil
		settingsProvider = nil
		analytics = nil
		soundPlayer = nil
	}
}

// MARK: - Helpers
private extension ContentPresenterTests {

	func waitForAnalyticsInvocation() async -> ContentAnalyticsServiceMock.Action? {
		await analytics.waitForInvocation()
	}
}

// MARK: - ViewDelegate test-cases
extension ContentPresenterTests {

	@Test func test_viewDidLoad_tracksDocumentShow() async {
		// Arrange
		let first = Item(text: "First")
		let second = Item(text: "Second")
		interactor.stubs.snapshot = Snapshot([
			Node(value: first, children: [Node(value: second)])
		])

		// Act
		sut.viewDidChange(state: .didLoad)
		let invocation = await waitForAnalyticsInvocation()

		// Assert
		guard case let .track(event) = invocation else {
			Issue.record("Expect track invocation")
			return
		}

		#expect(event.name == .screenShow)
		#expect(event.parameters["depth"] == 2)
		#expect(event.parameters["total_count"] == 2)
		#expect(event.parameters["is_root"] == true)
	}
}

// MARK: - ContentMenuDelegate test-cases
extension ContentPresenterTests {

	@Test func test_userDidTapMenuStrikethrough_tracksAnalytics() async {
		// Arrange
		let expectedId = UUID()

		// Act
		sut.userDidTapMenu(with: .toggleStrikethrough, selection: [expectedId])
		let invocation = await waitForAnalyticsInvocation()

		// Assert
		guard case let .track(event) = invocation else {
			Issue.record("Expect track invocation")
			return
		}

		#expect(event.name == .menuItemClick)
		#expect(event.parameters["id"] == "completed-toggle")
		#expect(event.parameters["source"] == "context-menu")
	}

	@Test func test_userDidTapMenuStrikethrough_playsMarkSound() {
		// Arrange
		let expectedId = UUID()

		// Act
		sut.userDidTapMenu(with: .toggleStrikethrough, selection: [expectedId])

		// Assert
		guard case let .setStatus(isStrikethrough, ids, moveToEnd) = interactor.invocations.first else {
			Issue.record("Expect setStatus invocation")
			return
		}

		guard case let .play(sound) = soundPlayer.invocations.first else {
			Issue.record("Expect play sound invocation")
			return
		}

		#expect(isStrikethrough)
		#expect(ids == [expectedId])
		#expect(moveToEnd == false)
		#expect(sound == .mark)
	}

	@Test func test_userDidTapMenuStrikethrough_whenSoundEffectsDisabled_doesNotPlaySound() {
		// Arrange
		let expectedId = UUID()
		settingsProvider.stubs.state = Settings(soundEffects: .disabled)

		// Act
		sut.userDidTapMenu(with: .toggleStrikethrough, selection: [expectedId])

		// Assert
		#expect(soundPlayer.invocations.isEmpty)
	}

	@Test func test_userDidTapMenuStrikethrough_whenItemIsCompleted_playsUnmarkSound() {
		// Arrange
		let expectedId = UUID()
		let item = Item(uuid: expectedId, text: .random, options: .strikethrough)
		let snapshot = Snapshot([Node(value: item)])
		sut.present(snapshot: snapshot)

		// Act
		sut.userDidTapMenu(with: .toggleStrikethrough, selection: [expectedId])

		// Assert
		guard case let .setStatus(isStrikethrough, ids, moveToEnd) = interactor.invocations.first else {
			Issue.record("Expect setStatus invocation")
			return
		}

		guard case let .play(sound) = soundPlayer.invocations.first else {
			Issue.record("Expect play sound invocation")
			return
		}

		#expect(!isStrikethrough)
		#expect(ids == [expectedId])
		#expect(moveToEnd == false)
		#expect(sound == .unmark)
	}
}

// MARK: - DropDelegate test-cases
extension ContentPresenterTests {

	@Test func test_moveItems_tracksAnalytics() async {
		// Arrange
		let expectedIds = [UUID(), UUID()]
		let expectedDestination: Destination<UUID> = .toRoot

		// Act
		sut.move(expectedIds, to: expectedDestination)
		let invocation = await waitForAnalyticsInvocation()

		// Assert
		guard case let .track(event) = invocation else {
			Issue.record("Expect track invocation")
			return
		}

		#expect(event.name == .dragDropMove)
		#expect(event.parameters["items_count"] == 2)
	}

	@Test func test_moveItems_playsPlaceSound() {
		// Arrange
		let expectedIds = [UUID(), UUID()]
		let expectedDestination: Destination<UUID> = .toRoot

		// Act
		sut.move(expectedIds, to: expectedDestination)

		// Assert
		guard case let .move(ids, destination) = interactor.invocations.first else {
			Issue.record("Expect move invocation")
			return
		}

		guard case let .play(sound) = soundPlayer.invocations.first else {
			Issue.record("Expect play sound invocation")
			return
		}

		#expect(ids == expectedIds)
		#expect(destination == expectedDestination)
		#expect(sound == .place)
	}

	@Test func test_moveItems_whenSoundEffectsDisabled_doesNotPlaySound() {
		// Arrange
		let expectedIds = [UUID(), UUID()]
		let expectedDestination: Destination<UUID> = .toRoot
		settingsProvider.stubs.state = Settings(soundEffects: .disabled)

		// Act
		sut.move(expectedIds, to: expectedDestination)

		// Assert
		#expect(soundPlayer.invocations.isEmpty)
	}
}
