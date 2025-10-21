//
//  ReorderViewModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.09.2025.
//

import SwiftUI

import Hierarchy
import CoreModule

@Observable
final class ReorderViewModel {

	let parent: UUID?

	var items: [ItemViewModel] = []

	@ObservationIgnored
	var storage: DocumentStorage<Content>

	// MARK: - Initialization

	init(item: UUID, storage: DocumentStorage<Content>) {
		self.parent = storage.state.root.node(with: item)?.parent?.id
		self.storage = storage

		self.present(root: storage.state.root)
		storage.addObservation(for: self) { [weak self] content in
			self?.present(root: content.root)
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

	func present(root: Root<Item>) {
		self.items = storage.state.root.children(of: parent)
			.map {
				$0.value
			}.map {
				ItemViewModel(
					id: $0.id,
					title: $0.text,
					textStyle: $0.style.isSection ? .headline : .body,
					icon: $0.style.semanticImage
				)
			}
	}
}
