//
//  TargetDestinationViewModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.09.2025.
//

import SwiftUI

import Hierarchy
import CoreModule

@Observable
final class TargetDestinationViewModel {

	let excludedIds: Set<UUID>

	var searchText: String = ""

	// MARK: - Computed Properties

	var filteredItems: [ItemViewModel] {
		items.filter { item in
			guard !searchText.isEmpty else {
				return !excludedIds.contains(item.id)
			}
			return item.title.lowercased().contains(searchText.lowercased()) && !excludedIds.contains(item.id)
		}
	}

	var unavailableItems: [ItemViewModel] {
		items.filter {
			return excludedIds.contains($0.id)
		}
	}

	var items: [ItemViewModel] = []

	@ObservationIgnored
	var storage: DocumentStorage<Content>

	// MARK: - Initialization

	init(storage: DocumentStorage<Content>, movingItems: Set<UUID>) {
		self.storage = storage
		self.excludedIds = storage.state.root.invalidTargets(movingItems: movingItems)

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

// MARK: - Helpers
private extension TargetDestinationViewModel {

	func present(root: Root<Item>) {
		self.items = storage.state.root
			.flattened { _ in true }.map {
				ItemViewModel(
					id: $0.id,
					title: $0.text,
					textStyle: $0.style.isSection ? .headline : .body,
					icon: $0.style.semanticImage,
					isDisabled: self.excludedIds.contains($0.id)
				)
			}
	}
}
