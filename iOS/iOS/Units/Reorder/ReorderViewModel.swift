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
	var storage: DocumentStorage<Content>

	// MARK: - Initialization

	init(item: UUID, storage: DocumentStorage<Content>) {
		self.parent = storage.state.root.parent(for: item)?.id
		self.storage = storage

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

	func move(fromOffsets source: IndexSet, toOffset destination: Int) {
		let ids = source.map { items[$0].id }
		storage.modificate { content in
			content.root.moveItems(with: ids, to: .init(target: parent, index: destination))
		}
	}
}

// MARK: - Helpers
private extension ReorderViewModel {

	func present(root: UUID?) {
		self.items = storage.state.root
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
}
