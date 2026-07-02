//
//  ItemColorPickerViewModel.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 02.07.2026.
//

import CoreModule
import DesignSystem
import Foundation

@MainActor final class ItemColorPickerViewModel {

	let title: String

	let colors: [ColorToken]

	private let action: @MainActor (ItemColor?, Bool) -> Void

	// MARK: - Initialization

	init(
		title: String,
		action: @escaping @MainActor (ItemColor?, Bool) -> Void
	) {
		self.title = title
		self.action = action
		self.colors = ItemColor.allCases.map {
			ColorMapper.map(color: $0)
		}
	}
}

// MARK: - Public Interface
extension ItemColorPickerViewModel {

	func selectNone() {
		action(nil, true)
	}

	func select(_ color: ColorToken) {
		action(ColorMapper.map(token: color), true)
	}

	func cancel() {
		action(nil, false)
	}
}
