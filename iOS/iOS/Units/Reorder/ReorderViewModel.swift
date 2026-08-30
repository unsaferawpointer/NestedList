//
//  ReorderViewModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.09.2025.
//

import SwiftUI

import Hierarchy
import CoreModule
import CorePresentation

@Observable
final class ReorderViewModel {

	let parent: UUID?

	var items: [ItemViewModel] = []

	@ObservationIgnored
	var storage: DocumentStorage<DocumentContent>

	@ObservationIgnored
	private let analytics: any ConcreteAnalyticsServiceProtocol<ReorderAnalyticsEvent>

	private var didTrackShow = false

	// MARK: - Initialization

	init(
		item: UUID,
		storage: DocumentStorage<DocumentContent>,
		analytics: any ConcreteAnalyticsServiceProtocol<ReorderAnalyticsEvent>
	) {
		self.parent = storage.state.parent(for: item)?.id
		self.storage = storage
		self.analytics = analytics

		self.present(root: parent)
		storage.addObservation(for: self) { [weak self] content in
			self?.present(root: self?.parent)
		}
	}

	// MARK: - Deinit

	deinit {
		storage.removeObserver(self)
	}
}

// MARK: - Public Interface
extension ReorderViewModel {

	func show() {
		guard !didTrackShow else {
			return
		}
		didTrackShow = true
		track(.show(itemsCount: items.count))
	}

	func close() {
		track(.closeButtonClick)
	}

	func move(fromOffsets source: IndexSet, toOffset destination: Int) {
		let ids = source.map { items[$0].id }
		do {
			try storage.modificate { content in
				try content.moveItems(with: ids, to: .init(target: parent, index: destination))
			}
			track(.dragDropMove(itemsCount: ids.count))
		} catch {
			// TODO: - Implement error handling
		}
	}
}

// MARK: - Private methods
private extension ReorderViewModel {

	func present(root: UUID?) {
		self.items = storage.state
			.snapshot()
			.children(of: root)
			.map {
				ItemViewModel(
					id: $0.id,
					title: $0.text,
					textStyle: .body,
					icon: IconMapper.map(icon: $0.iconName, filled: true)
				)
			}
	}

	func track(_ event: ReorderAnalyticsEvent) {
		let analytics = analytics
		Task {
			await analytics.track(event)
		}
	}
}
