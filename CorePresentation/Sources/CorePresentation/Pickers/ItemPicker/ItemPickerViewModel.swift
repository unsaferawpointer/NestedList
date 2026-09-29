//
//  ItemPickerViewModel.swift
//  CorePresentation
//

import CoreModule
import DesignSystem
import Foundation
import Observation

@MainActor @Observable final class ItemPickerViewModel {

	let title: String
	private(set) var items: [ItemPickerItem] = []

	var searchText = ""

	private let action: @MainActor (UUID?, Bool) -> Void
	private let analytics: any ConcreteAnalyticsServiceProtocol<ItemPickerAnalyticsEvent>
	private let filter: (Item) -> Bool

	@ObservationIgnored
	private let storage: DocumentStorage<DocumentContent>

	private var didTrackShow = false

	// MARK: - Initialization

	init(
		storage: DocumentStorage<DocumentContent>,
		title: String,
		filter: @escaping (Item) -> Bool,
		analytics: any ConcreteAnalyticsServiceProtocol<ItemPickerAnalyticsEvent>,
		action: @escaping @MainActor (UUID?, Bool) -> Void
	) {
		self.title = title
		self.analytics = analytics
		self.action = action
		self.filter = filter
		self.storage = storage

		present(content: storage.state)
		storage.addObservation(for: self) { [weak self] content in
			self?.present(content: content)
		}
	}

	isolated deinit {
		storage.removeObserver(self)
	}
}

// MARK: - Public Interface
extension ItemPickerViewModel {

	var filteredItems: [ItemPickerItem] {
		guard !searchText.isEmpty else {
			return items
		}

		let query = searchText.localizedLowercase
		return items.filter { $0.title.localizedLowercase.contains(query) }
	}

	func show() {
		guard !didTrackShow else {
			return
		}
		didTrackShow = true
		track(.itemPickerShow(itemsCount: items.count))
	}

	func select(_ item: ItemPickerItem) {
		track(.itemClick)
		action(item.id, true)
	}

	func cancel() {
		track(.cancelButtonClick)
		action(nil, false)
	}
}

// MARK: - Private Methods
private extension ItemPickerViewModel {

	func present(content: DocumentContent) {
		let snapshot = content.snapshot()
		items = snapshot
			.flattened { _ in true }
			.filter(filter)
			.map { item in
				ItemPickerItem(
					id: item.id,
					title: item.text,
					icon: IconMapper.map(icon: item.iconName, filled: true),
					level: snapshot.level(for: item.id)
				)
			}
	}

	func track(_ event: ItemPickerAnalyticsEvent) {
		let analytics = analytics
		Task {
			await analytics.track(event)
		}
	}
}

// MARK: - Nested Data Structures
struct ItemPickerItem: Identifiable {

	let id: UUID
	let title: String
	let icon: SemanticImage?
	let level: Int
}
