//
//  ItemDetailsViewModel.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 02.07.2026.
//

import Foundation
import DesignSystem

@MainActor
@Observable
final class ItemDetailsViewModel {

	var item: ItemDetailsView.Model

	let icons: [SemanticImage]

	private let completionHandler: (ItemDetailsView.Properties, Bool) -> Void

	init(item: ItemDetailsView.Model, completionHandler: @escaping (ItemDetailsView.Properties, Bool) -> Void) {
		self.item = item
		self.completionHandler = completionHandler
		self.icons = IconsPalette.chunked()
			.flatMap { $0 }
			.map { IconMapper.map(icon: $0) }
	}
}

// MARK: - Public Interface
extension ItemDetailsViewModel {

	var isValid: Bool {
		return !item.properties.text.isEmpty
	}

	var navigationTitle: String {
		return item.navigationTitle
	}

	var initialFocus: ItemDetailsView.Field? {
		return item.focus
	}

	func cancel() {
		completionHandler(item.properties, false)
	}

	func save() {
		completionHandler(item.properties, true)
	}

	func nextField(after field: ItemDetailsView.Field?) -> ItemDetailsView.Field? {
		switch field {
		case .title:
			return .note
		default:
			return nil
		}
	}
}
