//
//  ContentRouterMock.swift
//  iOSTests
//
//  Created by Anton Cherkasov on 06.07.2026.
//

import Foundation
import CoreModule
import CorePresentation
@testable import iOS

@MainActor
final class ContentRouterMock {

	private(set) var invocations: [Action] = []
}

// MARK: - ContentRouterProtocol
extension ContentRouterMock: ContentRouterProtocol {

	func showDetails(
		with model: ItemDetailsView.Model,
		animateBottomBarItem barItem: String?,
		completionHandler: @escaping @MainActor (ItemDetailsView.Properties, Bool) -> Void
	) {
		invocations.append(.showDetails(model: model, barItem: barItem))
	}

	func showSettings() {
		invocations.append(.showSettings)
	}

	func showTargetsScreen(for ids: Set<UUID>, completionHandler: @escaping (UUID?, Bool) -> Void) {
		invocations.append(.showTargetsScreen(ids: ids))
	}

	func showReorderScreen(for item: UUID, completionHandler: @escaping () -> Void) {
		invocations.append(.showReorderScreen(item: item))
	}

	func showIconPicker(title: String, completionHandler: @escaping @MainActor (IconName?) -> Void) {
		invocations.append(.showIconPicker(title: title))
	}

	func showColorPicker(title: String, completionHandler: @escaping @MainActor (ItemColor?) -> Void) {
		invocations.append(.showColorPicker(title: title))
	}

	func showDocument(for id: UUID) {
		invocations.append(.showDocument(id: id))
	}

	func dismiss() {
		invocations.append(.dismiss)
	}
}

// MARK: - Nested data structs
extension ContentRouterMock {

	enum Action {
		case showDetails(model: ItemDetailsView.Model, barItem: String?)
		case showSettings
		case showTargetsScreen(ids: Set<UUID>)
		case showReorderScreen(item: UUID)
		case showIconPicker(title: String)
		case showColorPicker(title: String)
		case showDocument(id: UUID)
		case dismiss
	}
}
