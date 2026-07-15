//
//  ReorderViewModelTests.swift
//  iOSTests
//
//  Created by Codex on 13.07.2026.
//

import Testing
import Foundation
import CoreModule
import CorePresentation
import Hierarchy
@testable import iOS

@MainActor
final class ReorderViewModelTests {

	@Test func test_show_tracksScreenShow() async {
		// Arrange
		let first = Item(text: "First")
		let second = Item(text: "Second")
		let analytics = ReorderAnalyticsServiceMock()
		let sut = makeSUT(items: [first, second], selected: first.id, analytics: analytics)

		// Act
		sut.show()
		let invocation = await waitForAnalyticsInvocation(in: analytics)

		// Assert
		guard case let .track(event) = invocation else {
			Issue.record("Expect track invocation")
			return
		}

		#expect(event.name == .screenShow)
		#expect(event.area == "reorder")
		#expect(event.parameters["items_count"] == 2)
	}

	@Test func test_close_tracksButtonClick() async {
		// Arrange
		let item = Item(text: "First")
		let analytics = ReorderAnalyticsServiceMock()
		let sut = makeSUT(items: [item], selected: item.id, analytics: analytics)

		// Act
		sut.close()
		let invocation = await waitForAnalyticsInvocation(in: analytics)

		// Assert
		guard case let .track(event) = invocation else {
			Issue.record("Expect track invocation")
			return
		}

		#expect(event.name == .buttonClick)
		#expect(event.area == "reorder")
		#expect(event.parameters["id"] == "close")
	}

	@Test func test_move_tracksDragDropMove() async {
		// Arrange
		let first = Item(text: "First")
		let second = Item(text: "Second")
		let third = Item(text: "Third")
		let analytics = ReorderAnalyticsServiceMock()
		let sut = makeSUT(items: [first, second, third], selected: first.id, analytics: analytics)

		// Act
		sut.move(fromOffsets: IndexSet([0, 1]), toOffset: 3)
		let invocation = await waitForAnalyticsInvocation(in: analytics)

		// Assert
		guard case let .track(event) = invocation else {
			Issue.record("Expect track invocation")
			return
		}

		#expect(event.name == .dragDropMove)
		#expect(event.area == "reorder")
		#expect(event.parameters["items_count"] == 2)
	}
}

// MARK: - Helpers
private extension ReorderViewModelTests {

	func makeSUT(
		items: [Item],
		selected: UUID,
		analytics: ReorderAnalyticsServiceMock
	) -> ReorderViewModel {
		let nodes = items.map { Node(value: $0) }
		let content = DocumentContent(uuid: UUID(), nodes: nodes)
		let storage = DocumentStorage(
			stateProvider: StateProvider(initialState: content),
			contentProvider: ContentProviderMock(),
			undoManager: nil
		)
		return ReorderViewModel(
			item: selected,
			storage: storage,
			analytics: analytics
		)
	}

	func waitForAnalyticsInvocation(
		in analytics: ReorderAnalyticsServiceMock
	) async -> ReorderAnalyticsServiceMock.Action? {
		await analytics.waitForInvocation()
	}
}

// MARK: - ReorderAnalyticsServiceMock
private actor ReorderAnalyticsServiceMock {

	private(set) var invocations: [Action] = []

	private var continuation: CheckedContinuation<Action?, Never>?
}

// MARK: - ReorderAnalyticsServiceProtocol
extension ReorderAnalyticsServiceMock: ReorderAnalyticsServiceProtocol {

	func track(_ event: ReorderAnalyticsEvent) async {
		append(.track(event))
	}
}

// MARK: - Public Interface
private extension ReorderAnalyticsServiceMock {

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
private extension ReorderAnalyticsServiceMock {

	func append(_ action: Action) {
		invocations.append(action)
		continuation?.resume(returning: action)
		continuation = nil
	}
}

// MARK: - Nested data structs
private extension ReorderAnalyticsServiceMock {

	enum Action {
		case track(ReorderAnalyticsEvent)
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
