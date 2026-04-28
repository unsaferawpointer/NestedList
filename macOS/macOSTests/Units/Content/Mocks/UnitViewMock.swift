//
//  UnitViewMock.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 25.01.2025.
//

import CoreModule
import Foundation
import Hierarchy
import CorePresentation
@testable import Nested_List

final class UnitViewMock {
	private(set) var invocations: [Action] = []
	var stubs = Stubs()

	func clear() {
		invocations.removeAll()
	}
}

// MARK: - ContentView
extension UnitViewMock: UnitView {

	func showDetails(with model: ItemDetailsView.Model, completionHandler: @escaping (ItemDetailsView.Properties, Bool) -> Void) {
		invocations.append(.showDetails(model: model, completionHandler: completionHandler))
	}
	
	func closeSheet() {
		invocations.append(.closeSheet)
	}

	func display(_ state: ContentViewState) {
		invocations.append(.display(state))
	}

	func expand(_ ids: [UUID]?) {
		invocations.append(.expand(ids))
	}
	
	func scroll(to id: UUID) {
		invocations.append(.scroll(id))
	}
	
	func select(_ id: UUID) {
		invocations.append(.select(id))
	}
	
	func focus(on id: UUID, key: String) {
		invocations.append(.focus(id, key: key))
	}
	
	var selection: [UUID] {
		get {
			stubs.selection
		}
		set {
			invocations.append(.didSetSelection(selection: newValue))
		}
	}
}

// MARK: - Nested data structs
extension UnitViewMock {

	enum Action {
		case display(_ snapshot: ContentViewState)
		case expand(_ ids: [UUID]?)
		case scroll(_ id: UUID)
		case select(_ id: UUID)
		case focus(_ id: UUID, key: String)
		case didSetSelection(selection: [UUID])
		case showDetails(model: ItemDetailsView.Model, completionHandler: (ItemDetailsView.Properties, Bool) -> Void)
		case closeSheet
	}

	struct Stubs {
		var selection: [UUID] = []
	}
}
