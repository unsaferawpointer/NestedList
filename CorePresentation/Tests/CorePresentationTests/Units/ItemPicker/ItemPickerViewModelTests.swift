import Analytics
import CoreModule
import Foundation
@testable import CorePresentation
import Testing

@MainActor struct ItemPickerViewModelTests { }

// MARK: - Filtering and Search
@MainActor extension ItemPickerViewModelTests {

	@Test func init_appliesFilterAndPreservesOutlineOrder() {
		// Arrange
		let first = Item(uuid: UUID(), text: "First")
		let second = Item(uuid: UUID(), text: "Second")
		let third = Item(uuid: UUID(), text: "Third")
		let storage = makeStorage(nodes: [
			DocumentNode(value: first, children: [
				DocumentNode(value: second, children: [])
			]),
			DocumentNode(value: third, children: [])
		])

		// Act
		let sut = makeSUT(storage: storage, allowedIDs: [first.id, third.id])

		// Assert
		#expect(sut.items.map(\.title) == ["First", "Third"])
	}

	@Test func filteredItems_appliesSearchToAcceptedItems() {
		// Arrange
		let first = Item(text: "Research")
		let second = Item(text: "Implementation")
		let sut = makeSUT(storage: makeStorage(nodes: [
			DocumentNode(value: first, children: []),
			DocumentNode(value: second, children: [])
		]))

		// Act
		sut.searchText = "research"

		// Assert
		#expect(sut.filteredItems.map(\.title) == ["Research"])
	}
}

// MARK: - Selection
@MainActor extension ItemPickerViewModelTests {

	@Test func select_tracksItemAndCompletesSuccessfully() async {
		// Arrange
		let analytics = ItemPickerAnalyticsMock()
		var result: (UUID?, Bool)?
		let item = Item(text: "Selected")
		let sut = makeSUT(storage: makeStorage(nodes: [
			DocumentNode(value: item, children: [])
		]), analytics: analytics) { id, success in
			result = (id, success)
		}

		// Act
		sut.select(sut.items[0])
		let event = await analytics.waitForEvent()

		// Assert
		#expect(event.name == .buttonClick)
		#expect(event.area == "item_picker")
		#expect(event.parameters["id"] == .string("select_item"))
		#expect(result?.0 == item.id)
		#expect(result?.1 == true)
	}

	@Test func cancel_tracksCancelAndCompletesUnsuccessfully() async {
		// Arrange
		let analytics = ItemPickerAnalyticsMock()
		var result: (UUID?, Bool)?
		let sut = makeSUT(analytics: analytics) { id, success in
			result = (id, success)
		}

		// Act
		sut.cancel()
		let event = await analytics.waitForEvent()

		// Assert
		#expect(event.name == .buttonClick)
		#expect(event.area == "item_picker")
		#expect(event.parameters["id"] == .string("cancel"))
		#expect(result?.0 == nil)
		#expect(result?.1 == false)
	}
}

// MARK: - Analytics
@MainActor extension ItemPickerViewModelTests {

	@Test func show_tracksOnlyOnceWithDisplayedItemCount() async {
		// Arrange
		let analytics = ItemPickerAnalyticsMock()
		let sut = makeSUT(analytics: analytics)

		// Act
		sut.show()
		sut.show()
		let event = await analytics.waitForEvent()
		let events = await analytics.trackedEvents()

		// Assert
		#expect(event.name == .screenShow)
		#expect(event.area == "item_picker")
		#expect(event.parameters["items_count"] == .int(1))
		#expect(events.count == 1)
	}
}

// MARK: - Helpers
@MainActor private extension ItemPickerViewModelTests {

	func makeSUT(
		storage: DocumentStorage<DocumentContent>? = nil,
		analytics: ItemPickerAnalyticsMock = ItemPickerAnalyticsMock(),
		allowedIDs: Set<UUID>? = nil,
		action: @escaping @MainActor (UUID?, Bool) -> Void = { _, _ in }
	) -> ItemPickerViewModel {
		let storage = storage ?? makeStorage()
		return ItemPickerViewModel(
			storage: storage,
			title: "Choose Item",
			allowedIDs: allowedIDs ?? Set(storage.state.snapshot().flattened { _ in true }.map(\.id)),
			analytics: analytics,
			action: action
		)
	}

	func makeStorage(nodes: [DocumentNode<Item>] = [DocumentNode(value: Item(text: "Item"), children: [])]) -> DocumentStorage<DocumentContent> {
		DocumentStorage(
			stateProvider: StateProvider(initialState: DocumentContent(uuid: nil, nodes: nodes)),
			contentProvider: JsonDataProvider(),
			undoManager: nil
		)
	}
}

// MARK: - Analytics Mock
private actor ItemPickerAnalyticsMock {

	private var events: [ItemPickerAnalyticsEvent] = []
	private var eventContinuation: CheckedContinuation<ItemPickerAnalyticsEvent, Never>?

	func trackedEvents() -> [ItemPickerAnalyticsEvent] {
		events
	}

	func waitForEvent() async -> ItemPickerAnalyticsEvent {
		if let event = events.first {
			return event
		}
		return await withCheckedContinuation { continuation in
			eventContinuation = continuation
		}
	}
}

// MARK: - ConcreteAnalyticsServiceProtocol
extension ItemPickerAnalyticsMock: ConcreteAnalyticsServiceProtocol<ItemPickerAnalyticsEvent> {

	func track(_ event: ItemPickerAnalyticsEvent) async {
		events.append(event)
		eventContinuation?.resume(returning: event)
		eventContinuation = nil
	}
}
