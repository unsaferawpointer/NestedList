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
	private let analytics: any PickerAnalyticsServiceProtocol

	private var didTrackShow = false

	// MARK: - Initialization

	init(
		title: String,
		analytics: any PickerAnalyticsServiceProtocol,
		action: @escaping @MainActor (ItemColor?, Bool) -> Void
	) {
		self.title = title
		self.analytics = analytics
		self.action = action
		self.colors = ItemColor.allCases.map {
			ColorMapper.map(color: $0)
		}
	}
}

// MARK: - Public Interface
extension ItemColorPickerViewModel {

	func show() {
		guard !didTrackShow else {
			return
		}
		didTrackShow = true
		track(.colorPickerShow)
	}

	func selectNone() {
		track(.colorClick(rawValue: nil))
		action(nil, true)
	}

	func select(_ color: ColorToken) {
		let itemColor = ColorMapper.map(token: color)
		if let rawValue = itemColor?.rawValue {
			track(.colorClick(rawValue: rawValue))
		}
		action(itemColor, true)
	}

	func cancel() {
		track(.colorPickerCancelButtonClick)
		action(nil, false)
	}
}

// MARK: - Private methods
private extension ItemColorPickerViewModel {

	func track(_ event: PickerAnalyticsEvent) {
		let analytics = analytics
		Task {
			await analytics.track(event)
		}
	}
}
