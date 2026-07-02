//
//  IconPickerViewModel.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 02.07.2026.
//

import CoreModule
import DesignSystem
import Foundation

@MainActor final class IconPickerViewModel {

	let title: String

	let icons: [SemanticImage]

	private let action: @MainActor (IconName?, Bool) -> Void

	// MARK: - Initialization

	init(
		title: String,
		action: @escaping @MainActor (IconName?, Bool) -> Void
	) {
		self.title = title
		self.action = action
		self.icons = IconName.allCases.map {
			IconMapper.map(icon: $0)
		}
	}
}

// MARK: - Public Interface
extension IconPickerViewModel {

	func selectNone() {
		action(nil, true)
	}

	func select(_ icon: SemanticImage) {
		action(IconMapper.map(icon: icon), true)
	}

	func cancel() {
		action(nil, false)
	}
}
