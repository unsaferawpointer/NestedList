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
	private let analytics: any PickerAnalyticsServiceProtocol

	private var didTrackShow = false

	// MARK: - Initialization

	init(
		title: String,
		analytics: any PickerAnalyticsServiceProtocol,
		action: @escaping @MainActor (IconName?, Bool) -> Void
	) {
		self.title = title
		self.analytics = analytics
		self.action = action
		self.icons = IconName.allCases.map {
			IconMapper.map(icon: $0)
		}
	}
}

// MARK: - Public Interface
extension IconPickerViewModel {

	func show() {
		guard !didTrackShow else {
			return
		}
		didTrackShow = true
		track(.iconPickerShow)
	}

	func selectNone() {
		track(.iconClick(rawValue: nil))
		action(nil, true)
	}

	func select(_ icon: SemanticImage) {
		let iconName = IconMapper.map(icon: icon)
		if let rawValue = iconName?.rawValue {
			track(.iconClick(rawValue: rawValue))
		}
		action(iconName, true)
	}

	func cancel() {
		track(.iconPickerCancelButtonClick)
		action(nil, false)
	}
}

// MARK: - Private methods
private extension IconPickerViewModel {

	func track(_ event: PickerAnalyticsEvent) {
		let analytics = analytics
		Task {
			await analytics.track(event)
		}
	}
}
