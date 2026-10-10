//
//  ContentPresenterTests.swift
//  iOSTests
//
//  Created by Anton Cherkasov on 06.07.2026.
//

import Testing
import Foundation
import UIKit
import UniformTypeIdentifiers
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
	var analytics: ContentAnalyticsMock!
	var soundPlayer: SoundPlayerMock!

	init() {
		interactor = ContentUnitInteractorMock()
		router = ContentRouterMock()
		settingsProvider = StateProviderMock<Settings>()
		settingsProvider.stubs.state = Settings()
		analytics = ContentAnalyticsMock()
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

	var itemType: String {
		"dev.zeroindex.ListAdapter.item"
	}

	var stringType: String {
		UTType.plainText.identifier
	}

	func waitForAnalyticsInvocation() async -> ContentAnalyticsMock.Action? {
		await analytics.waitForInvocation()
	}

	func clearPasteboard() {
		UIPasteboard.general.items = []
	}
}

// MARK: - ViewDelegate test-cases
extension ContentPresenterTests {

	@Test func test_viewDidLoad_tracksDocumentShow() async {
		// Arrange
		let first = Item(text: "First")
		let second = Item(text: "Second")
		interactor.stubs.snapshot = Snapshot([
			DocumentNode(value: first, children: [
				DocumentNode(value: second, children: [])
			])
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

	@Test func test_userDidTapMenuAddMirror_opensItemPicker() {
		// Arrange
		let expectedTarget = UUID()
		let expectedSource = UUID()
		interactor.stubs.mirrorSourceIDs = [expectedSource]

		// Act
		sut.userDidTapMenu(with: .addMirror, selection: [expectedTarget])

		// Assert
		guard case let .showItemPicker(title) = router.invocations.first else {
			Issue.record("Expect show item picker invocation")
			return
		}

		#expect(title == MenuLocalization().addMirrorItemTitle)
		#expect(router.showItemPickerAllowedIDs == [expectedSource])
		#expect(interactor.invocations.contains { action in
			guard case let .mirrorSourceIDs(destination) = action else {
				return false
			}
			return destination == .onItem(with: expectedTarget)
		})
	}

	@Test func test_userDidTapMenuAddMirror_createsMirrorFromPickedSource() {
		// Arrange
		let expectedTarget = UUID()
		let expectedSource = UUID()
		sut.userDidTapMenu(with: .addMirror, selection: [expectedTarget])

		// Act
		router.showItemPickerCompletionHandler?(expectedSource, true)

		// Assert
		guard case let .createMirror(reference, target) = interactor.invocations.last else {
			Issue.record("Expect createMirror invocation")
			return
		}

		#expect(reference == expectedSource)
		#expect(target == expectedTarget)
	}

	@Test func test_userDidTapMenuAddMirror_tracksAnalyticsWithoutChangingContent() async {
		// Arrange
		let expectedId = UUID()

		// Act
		sut.userDidTapMenu(with: .addMirror, selection: [expectedId])
		let invocation = await waitForAnalyticsInvocation()

		// Assert
		guard case let .track(event) = invocation else {
			Issue.record("Expect track invocation")
			return
		}

		#expect(event.name == .menuItemClick)
		#expect(event.parameters["id"] == "add-mirror")
		#expect(event.parameters["source"] == "context-menu")
		#expect(interactor.invocations.contains { action in
			guard case let .mirrorSourceIDs(destination) = action else {
				return false
			}
			return destination == .onItem(with: expectedId)
		})
	}

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
		let snapshot = Snapshot([
			DocumentNode(value: item, children: [])
		])
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

	@Test func test_userDidTapMenuCopyItems_writesItemAndTextDataToPasteboard() {
		// Arrange
		clearPasteboard()
		let expectedId = UUID()
		let expectedData = Data([1, 2, 3])
		let child = Item(text: "Child")
		let item = Item(uuid: expectedId, text: "Parent")
		interactor.stubs.nodes = [
			DocumentNode(value: item, children: [
				DocumentNode(value: child, children: [])
			])
		]
		interactor.stubs.data = expectedData

		// Act
		sut.userDidTapMenu(with: .copyItems, selection: [expectedId])

		// Assert
		let info = Pasteboard().getInfo()
		let data = info?.items.first?.data

		#expect(data?[itemType] == expectedData)
		#expect(String(data: data?[stringType] ?? Data(), encoding: .utf8) == "- Parent :\n\t- Child")
	}

	@Test func test_userDidTapMenuCutItems_deletesItemsAfterWritingPasteboard() {
		// Arrange
		clearPasteboard()
		let expectedId = UUID()
		let expectedData = Data([4, 5, 6])
		let item = Item(uuid: expectedId, text: "Cut item")
		interactor.stubs.nodes = [
			DocumentNode(value: item, children: [])
		]
		interactor.stubs.data = expectedData

		// Act
		sut.userDidTapMenu(with: .cutItems, selection: [expectedId])

		// Assert
		guard case let .deleteItems(ids) = interactor.invocations.last else {
			Issue.record("Expect delete items invocation")
			return
		}

		let info = Pasteboard().getInfo()

		#expect(ids == [expectedId])
		#expect(info?.items.first?.data[itemType] == expectedData)
	}

	@Test func test_userDidTapMenuPaste_withItemData_insertsItemsToSelectedDestination() {
		// Arrange
		clearPasteboard()
		let expectedId = UUID()
		let expectedData = Data([7, 8, 9])
		let info = PasteboardInfo(
			items: [
				PasteboardInfo.Item(
					data: [
						itemType: expectedData,
						stringType: Data()
					]
				)
			]
		)
		Pasteboard().setInfo(info, clearContents: true)

		// Act
		sut.userDidTapMenu(with: .paste, selection: [expectedId])

		// Assert
		guard case let .insertItems(data, destination) = interactor.invocations.first else {
			Issue.record("Expect insert items invocation")
			return
		}

		#expect(data == [expectedData])
		#expect(destination == .onItem(with: expectedId))
	}

	@Test func test_userDidTapMenuPaste_withTextData_insertsStringsToRoot() {
		// Arrange
		clearPasteboard()
		let expectedText = "Pasted text"
		UIPasteboard.general.items = [
			[
				stringType: expectedText
			]
		]

		// Act
		sut.userDidTapMenu(with: .paste, selection: [])

		// Assert
		guard case let .insertStringData(data, destination) = interactor.invocations.first else {
			Issue.record("Expect insert string data invocation")
			return
		}

		let strings = data.compactMap { String(data: $0, encoding: .utf8) }

		#expect(strings == [expectedText])
		#expect(destination == .toRoot)
	}
}

// MARK: - ContentToolbarDelegate test-cases
extension ContentPresenterTests {

	@Test func test_userDidTapToolbarAddMirror_opensItemPickerAndTracksAnalytics() async {
		// Arrange
		let expectedTarget = UUID()
		let expectedSource = UUID()
		interactor.stubs.mirrorSourceIDs = [expectedSource]

		// Act
		sut.userDidTapToolbar(with: .addMirror, selection: [expectedTarget])
		let invocation = await waitForAnalyticsInvocation()

		// Assert
		guard case let .showItemPicker(title) = router.invocations.first else {
			Issue.record("Expect show item picker invocation")
			return
		}

		#expect(title == MenuLocalization().addMirrorItemTitle)
		#expect(router.showItemPickerAllowedIDs == [expectedSource])
		guard case let .track(event) = invocation else {
			Issue.record("Expect track invocation")
			return
		}

		#expect(event.name == .menuItemClick)
		#expect(event.parameters["id"] == .string("add-mirror"))
		#expect(event.parameters["source"] == .string(MenuSource.toolbar.rawValue))
	}

	@Test func test_userDidTapToolbarNewItem_tracksAnalytics() async {
		// Arrange
		let expectedTarget = UUID()

		// Act
		sut.userDidTapToolbar(with: .newItem, selection: [expectedTarget])
		let invocation = await waitForAnalyticsInvocation()

		// Assert
		guard case let .track(event) = invocation else {
			Issue.record("Expect track invocation")
			return
		}

		#expect(event.name == .menuItemClick)
		#expect(event.parameters["id"] == .string("new-item"))
		#expect(event.parameters["source"] == .string(MenuSource.toolbar.rawValue))
	}
}

// MARK: - DropDelegate test-cases
extension ContentPresenterTests {

	@Test func test_moveItems_tracksAnalytics() async {
		// Arrange
		let expectedIds = [UUID(), UUID()]
		let expectedDestination: Destination<UUID> = .toRoot
		interactor.stubs.validateMovement = true

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
		interactor.stubs.validateMovement = true

		// Act
		sut.move(expectedIds, to: expectedDestination)

		// Assert
		guard let move = interactor.invocations.first(where: { action in
			guard case .move = action else {
				return false
			}
			return true
		}), case let .move(ids, destination) = move else {
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
		interactor.stubs.validateMovement = true

		// Act
		sut.move(expectedIds, to: expectedDestination)

		// Assert
		#expect(soundPlayer.invocations.isEmpty)
	}

	@Test func test_moveItems_whenMovementInvalid_doesNotMove() {
		// Arrange
		let ids = [UUID()]
		let destination: Destination<UUID> = .toRoot
		interactor.stubs.validateMovement = false

		// Act
		sut.move(ids, to: destination)

		// Assert
		#expect(interactor.invocations.contains { action in
			guard case let .validateMovement(actualIDs, actualDestination) = action else {
				return false
			}
			return actualIDs == ids && actualDestination == destination
		})
		#expect(!interactor.invocations.contains { action in
			guard case .move = action else {
				return false
			}
			return true
		})
		#expect(soundPlayer.invocations.isEmpty)
	}
}
