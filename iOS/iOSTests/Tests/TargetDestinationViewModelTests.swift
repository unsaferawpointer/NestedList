//
//  TargetDestinationViewModelTests.swift
//  iOSTests
//
//  Created by Codex on 13.07.2026.
//

import Testing
import Foundation
import CoreModule
import Hierarchy
@testable import iOS

@MainActor
final class TargetDestinationViewModelTests {

	@Test func test_show_tracksScreenShow() async {
		// Arrange
		let first = Item(text: "First")
		let second = Item(text: "Second")
		let analytics = TargetDestinationAnalyticsServiceMock()
		let sut = makeSUT(items: [first, second], movingItems: [first.id], analytics: analytics)

		// Act
		sut.show()
		let invocation = await waitForAnalyticsInvocation(in: analytics)

		// Assert
		guard case let .track(event) = invocation else {
			Issue.record("Expect track invocation")
			return
		}

		#expect(event.name == .screenShow)
		#expect(event.area == "target_destination")
		#expect(event.parameters["available_items_count"] == 1)
		#expect(event.parameters["unavailable_items_count"] == 1)
	}

	@Test func test_selectRoot_tracksButtonClick() async {
		// Arrange
		let item = Item(text: "First")
		let analytics = TargetDestinationAnalyticsServiceMock()
		let sut = makeSUT(items: [item], movingItems: [], analytics: analytics)

		// Act
		sut.selectRoot()
		let invocation = await waitForAnalyticsInvocation(in: analytics)

		// Assert
		guard case let .track(event) = invocation else {
			Issue.record("Expect track invocation")
			return
		}

		#expect(event.name == .buttonClick)
		#expect(event.area == "target_destination")
		#expect(event.parameters["id"] == "select_root")
	}

	@Test func test_selectItem_tracksButtonClick() async {
		// Arrange
		let item = Item(text: "First")
		let analytics = TargetDestinationAnalyticsServiceMock()
		let sut = makeSUT(items: [item], movingItems: [], analytics: analytics)

		// Act
		sut.selectItem()
		let invocation = await waitForAnalyticsInvocation(in: analytics)

		// Assert
		guard case let .track(event) = invocation else {
			Issue.record("Expect track invocation")
			return
		}

		#expect(event.name == .buttonClick)
		#expect(event.area == "target_destination")
		#expect(event.parameters["id"] == "select_item")
	}

	@Test func test_close_tracksButtonClick() async {
		// Arrange
		let item = Item(text: "First")
		let analytics = TargetDestinationAnalyticsServiceMock()
		let sut = makeSUT(items: [item], movingItems: [], analytics: analytics)

		// Act
		sut.close()
		let invocation = await waitForAnalyticsInvocation(in: analytics)

		// Assert
		guard case let .track(event) = invocation else {
			Issue.record("Expect track invocation")
			return
		}

		#expect(event.name == .buttonClick)
		#expect(event.area == "target_destination")
		#expect(event.parameters["id"] == "close")
	}
}

// MARK: - Helpers
private extension TargetDestinationViewModelTests {

	func makeSUT(
		items: [Item],
		movingItems: Set<UUID>,
		analytics: TargetDestinationAnalyticsServiceMock
	) -> TargetDestinationViewModel {
		let nodes = items.map { Node(value: $0) }
		let content = Content(uuid: UUID(), nodes: nodes)
		let storage = DocumentStorage(
			stateProvider: StateProvider(initialState: content),
			contentProvider: ContentProviderMock(),
			undoManager: nil
		)
		return TargetDestinationViewModel(
			storage: storage,
			movingItems: movingItems,
			analytics: analytics
		)
	}

	func waitForAnalyticsInvocation(
		in analytics: TargetDestinationAnalyticsServiceMock
	) async -> TargetDestinationAnalyticsServiceMock.Action? {
		await analytics.waitForInvocation()
	}
}

// MARK: - TargetDestinationAnalyticsServiceMock
private actor TargetDestinationAnalyticsServiceMock {

	private(set) var invocations: [Action] = []

	private var continuation: CheckedContinuation<Action?, Never>?
}

// MARK: - TargetDestinationAnalyticsServiceProtocol
extension TargetDestinationAnalyticsServiceMock: TargetDestinationAnalyticsServiceProtocol {

	func track(_ event: TargetDestinationAnalyticsEvent) async {
		append(.track(event))
	}
}

// MARK: - Public Interface
private extension TargetDestinationAnalyticsServiceMock {

	func waitForInvocation() async -> Action? {
		if let invocation = invocations.first {
			return invocation
		}
		return await withCheckedContinuation { continuation in
			self.continuation = continuation
		}
	}
}

// MARK: - Private methods
private extension TargetDestinationAnalyticsServiceMock {

	func append(_ action: Action) {
		invocations.append(action)
		continuation?.resume(returning: action)
		continuation = nil
	}
}

// MARK: - Nested data structs
private extension TargetDestinationAnalyticsServiceMock {

	enum Action {
		case track(TargetDestinationAnalyticsEvent)
	}
}

// MARK: - ContentProviderMock
private final class ContentProviderMock { }

// MARK: - ContentProvider
extension ContentProviderMock: ContentProvider {

	func data(ofType typeName: String, content: Content) throws -> Data {
		try JSONEncoder().encode(content)
	}

	func read(from data: Data, ofType typeName: String) throws -> Content {
		try JSONDecoder().decode(Content.self, from: data)
	}
}
