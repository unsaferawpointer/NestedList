//
//  ColumnPresenter.swift
//  Nested List
//
//  Created by Anton Cherkasov on 16.08.2025.
//

import Foundation
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

	var localization: ColumnLocalizationProtocol

	// MARK: - Initialization

	init(localization: ColumnLocalizationProtocol = ColumnLocalization()) {
		self.localization = localization
	}
}

// MARK: - ColumnsViewOutput
extension ColumnPresenter: ColumnViewOutput {

	func viewDidChange(state: ViewState) {
		guard state == .didLoad else {
			return
		}
		interactor?.fetchData()
	}

	func userClickedOnPlusButton() {

		let target = view?.selection.first

		let details = DetailsView.Properties.init(text: localization.newItemText)

		let model = DetailsView.Model(navigationTitle: localization.newItemDetailsTitle, properties: details)
		view?.showDetails(with: model) { [weak self] saved, success in
			self?.view?.hideDetails()
			if success {
				let note = saved.description.isEmpty ? nil : saved.description
				let style: ItemStyle = saved.isSection ? .section(icon: saved.icon) : .item

				guard let id = self?.interactor?.newItem(
					saved.text,
					isStrikethrough: saved.isStrikethrough,
					note: note,
					isMarked: saved.isMarked,
					style: style,
					target: target
				) else {
					return
				}
				if let target {
					self?.view?.expand([target])
				}
				self?.view?.scroll(to: id)
			}
		}
	}
}

// MARK: - MenuDelegate
extension ColumnPresenter: MenuDelegate {

	func menuItemClicked(_ item: ElementIdentifier) {
		switch item {
		case .columnNewItem:
			fatalError()
		case .columnEdit:
			editItem()
		case .columnDelete:
			interactor?.deleteColumn()
		case .moveForward:
			interactor?.moveForward()
		case .moveBackward:
			interactor?.moveBackward()
		default:
			fatalError()
		}
	}
	
	func validateMenuItem(_ item: ElementIdentifier) -> Bool {
		switch item {
		case .moveForward:
			interactor?.validateMovingForward() ?? false
		case .moveBackward:
			interactor?.validateMovingBackward() ?? false
		default:
			true
		}
	}
	
	func isHidden(_ item: ElementIdentifier) -> Bool {
		return false
	}
	
	func stateForMenuItem(_ item: ElementIdentifier) -> ControlState {
		return .off
	}
	
	func menuItems() -> [ElementIdentifier] {
		return [.columnEdit, .separator, .moveForward, .moveBackward, .separator, .columnDelete]
	}
}

// MARK: - ColumnsPresenterProtocol
extension ColumnPresenter: ColumnPresenterProtocol {

	func present(_ item: Item) {
		view?.display(item.text)
	}
}

// MARK: - Helpers
private extension ColumnPresenter {

	func editItem() {
		guard let item = interactor?.rootItem()?.value else {
			return
		}
		let details = DetailsView.Properties(
			text: item.text,
			description: item.note ?? "",
			isStrikethrough: item.isStrikethrough,
			isMarked: item.isMarked,
			isSection: item.style != .item,
			icon: item.style.icon
		)
		let model = DetailsView.Model(
			navigationTitle: localization.editItemDetailsTitle,
			properties: details
		)
		view?.showDetails(with: model) { [weak self] saved, success in
			self?.view?.hideDetails()
			if success {
				let note = saved.description.isEmpty ? nil : saved.description
				let style: ItemStyle = saved.isSection ? .section(icon: saved.icon) : .item

				self?.interactor?.set(
					saved.text,
					isStrikethrough: saved.isStrikethrough,
					note: note,
					isMarked: saved.isMarked,
					style: style
				)
			}
		}
	}
}
