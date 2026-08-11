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
import CorePresentation
@testable import iOS

@MainActor
final class TargetDestinationViewModelTests {

	@Test func test_show_tracksScreenShow() async {
		// Arrange
		let first = Item(text: "First")
		let second = Item(text: "Second")
		let analytics = TargetDestinationAnalyticsMock()
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
		let analytics = TargetDestinationAnalyticsMock()
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
		let analytics = TargetDestinationAnalyticsMock()
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
		let analytics = TargetDestinationAnalyticsMock()
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
		analytics: TargetDestinationAnalyticsMock
	) -> TargetDestinationViewModel {
		let nodes = items.map { Node(value: $0) }
		let content = DocumentContent(uuid: UUID(), nodes: nodes)
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
		in analytics: TargetDestinationAnalyticsMock
	) async -> TargetDestinationAnalyticsMock.Action? {
		await analytics.waitForInvocation()
	}
}

// MARK: - TargetDestinationAnalyticsMock
private actor TargetDestinationAnalyticsMock {

	private(set) var invocations: [Action] = []

	private var continuation: CheckedContinuation<Action?, Never>?
}

// MARK: - ConcreteAnalyticsServiceProtocol<TargetDestinationAnalyticsEvent>
extension TargetDestinationAnalyticsMock: ConcreteAnalyticsServiceProtocol<TargetDestinationAnalyticsEvent> {

	func track(_ event: TargetDestinationAnalyticsEvent) async {
		append(.track(event))
	}
}

// MARK: - Public Interface
private extension TargetDestinationAnalyticsMock {

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
private extension TargetDestinationAnalyticsMock {

	func append(_ action: Action) {
		invocations.append(action)
		continuation?.resume(returning: action)
		continuation = nil
	}
}

// MARK: - Nested data structs
private extension TargetDestinationAnalyticsMock {

	enum Action {
		case track(TargetDestinationAnalyticsEvent)
	}
}

// MARK: - ContentProviderMock
private final class ContentProviderMock { }

// MARK: - ContentProvider
extension ContentProviderMock: ContentProvider {

	func data(ofType typeName: String, content: DocumentContent) throws -> Data {
		try JSONEncoder().encode(content)
	}

	func read(from data: Data, ofType typeName: String) throws -> DocumentContent {
		try JSONDecoder().decode(DocumentContent.self, from: data)
	}
}
