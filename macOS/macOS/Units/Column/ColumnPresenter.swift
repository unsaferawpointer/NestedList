//
//  ColumnPresenter.swift
//  Nested List
//
//  Created by Anton Cherkasov on 16.08.2025.
//

import Hierarchy
import CoreModule
import DesignSystem

protocol ColumnPresenterProtocol: AnyObject {
	func present(_ item: Item)
}

final class ColumnPresenter {

	// MARK: - DI

	var interactor: ColumnInteractorProtocol?

	weak var view: ColumnUnitView?
}

// MARK: - ColumnsViewOutput
extension ColumnPresenter: ColumnViewOutput {

	func viewDidChange(state: ViewState) {
		guard state == .didLoad else {
			return
		}
		interactor?.fetchData()
	}
}

// MARK: - MenuDelegate
extension ColumnPresenter: MenuDelegate {

	func menuItemClicked(_ item: ElementIdentifier) {
		switch item {
		case .columnNewItem:
			fatalError()
		case .columnEdit:
			fatalError()
		case .columnDelete:
			interactor?.deleteColumn()
		case .moveForward:
			fatalError()
		case .moveBackward:
			fatalError()
		default:
			fatalError()
		}
	}
	
	func validateMenuItem(_ item: ElementIdentifier) -> Bool {
		return true
	}
	
	func isHidden(_ item: ElementIdentifier) -> Bool {
		return false
	}
	
	func stateForMenuItem(_ item: ElementIdentifier) -> ControlState {
		return .off
	}
	
	func menuItems() -> [ElementIdentifier] {
		return [.columnNewItem, .separator, .columnEdit, .separator, .moveForward, .moveBackward, .separator, .columnDelete]
	}
}

// MARK: - ColumnsPresenterProtocol
extension ColumnPresenter: ColumnPresenterProtocol {

	func present(_ item: Item) {
		view?.display(item.text)
	}
}
