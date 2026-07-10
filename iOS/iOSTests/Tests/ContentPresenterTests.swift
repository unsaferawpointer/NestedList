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
import Hierarchy
@testable import iOS

@MainActor
final class ContentPresenterTests {

	var sut: ContentPresenter!

	// MARK: - DI

	var interactor: ContentUnitInteractorMock!
	var router: ContentRouterMock!
	var settingsProvider: StateProviderMock<Settings>!
	var soundPlayer: SoundPlayerMock!

	init() {
		interactor = ContentUnitInteractorMock()
		router = ContentRouterMock()
		settingsProvider = StateProviderMock<Settings>()
		settingsProvider.stubs.state = Settings()
		soundPlayer = SoundPlayerMock()
		sut = ContentPresenter(
			router: router,
			settingsProvider: settingsProvider,
			soundPlayer: soundPlayer
		)
		sut.interactor = interactor
	}

	deinit {
		sut = nil
		interactor = nil
		router = nil
		settingsProvider = nil
		soundPlayer = nil
	}
}

// MARK: - ContentMenuDelegate test-cases
extension ContentPresenterTests {

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
}
