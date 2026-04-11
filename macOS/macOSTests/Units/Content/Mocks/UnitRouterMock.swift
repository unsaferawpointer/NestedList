//
//  UnitRouterMock.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 11.04.2026.
//

import Foundation
import CoreModule
@testable import Nested_List

final class UnitRouterMock {

	private(set) var invocations: [Action] = []
	var stubs = Stubs()

	func clear() {
		invocations.removeAll()
		stubs = Stubs()
	}
}

// MARK: - RouterProtocol
extension UnitRouterMock: RouterProtocol {

	func showDetails(
		with model: ItemDetailsView.Model,
		completionHandler: @escaping (ItemDetailsView.Properties) -> Void
	) {
		stubs.showDetailsCompletionHandler = completionHandler
		invocations.append(.showDetails(model: model))
	}

	func showIconPicker(
		navigationTitle: String,
		completionHandler: @escaping @MainActor (IconName?) -> Void
	) {
		stubs.showIconPickerCompletionHandler = completionHandler
		invocations.append(.showIconPicker(navigationTitle: navigationTitle))
	}
}

// MARK: - Nested data structs
extension UnitRouterMock {

	enum Action {
		case showDetails(model: ItemDetailsView.Model)
		case showIconPicker(navigationTitle: String)
	}

	struct Stubs {
		var showDetailsCompletionHandler: ((ItemDetailsView.Properties) -> Void)?
		var showIconPickerCompletionHandler: (@MainActor (IconName?) -> Void)?
	}
}
