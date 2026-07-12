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
	private let analytics: any ItemDetailsAnalyticsServiceProtocol

	// MARK: - Analytics

	private let initialTextLength: Int
	private let mode: ItemDetailsView.Mode

	private var didTrackShow = false

	init(
		item: ItemDetailsView.Model,
		analytics: any ItemDetailsAnalyticsServiceProtocol,
		completionHandler: @escaping (ItemDetailsView.Properties, Bool) -> Void
	) {
		self.item = item
		self.analytics = analytics
		self.completionHandler = completionHandler

		self.initialTextLength = item.properties.text.count
		self.mode = item.properties.text.isEmpty ? .create : .edit

		self.icons = IconsPalette.chunked()
			.flatMap { $0 }
			.map { IconMapper.map(icon: $0) }
	}
}

// MARK: - Public Interface
extension ItemDetailsViewModel {

	func show() {
		guard !didTrackShow else {
			return
		}
		didTrackShow = true
		track(.itemDetailsShow(initialTextLength: initialTextLength, mode: mode))
	}

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
		track(.itemDetailsCancelButtonClick)
		completionHandler(item.properties, false)
	}

	func save() {
		track(.itemDetailsSaveButtonClick)
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

// MARK: - Private methods
private extension ItemDetailsViewModel {

	func track(_ event: ItemDetailsAnalyticsEvent) {
		let analytics = analytics
		Task {
			await analytics.track(event)
		}
	}
}
