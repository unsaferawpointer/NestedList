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
import CoreSettings

protocol ColumnPresenterProtocol: AnyObject {
	func present(_ item: Item)
}

final class ColumnPresenter {

	// MARK: - DI

	var interactor: ColumnInteractorProtocol?

	weak var view: ColumnUnitView?

	var router: RouterProtocol

	var localization: ColumnLocalizationProtocol

	private(set) var settingsProvider: any StateProviderProtocol<Settings>

	private let factory: ItemsFactoryProtocol

	// MARK: - Initialization

	init(
		router: RouterProtocol,
		settingsProvider: any StateProviderProtocol<Settings> = SettingsProvider.shared,
		localization: ColumnLocalizationProtocol = ColumnLocalization(),
		factory: ItemsFactoryProtocol = ItemsFactory()
	) {
		self.router = router
		self.settingsProvider = settingsProvider
		self.localization = localization
		self.factory = factory

		settingsProvider.addObservation(for: self) { [weak self] settings in
			self?.interactor?.fetchData()
		}
	}

	deinit {
		settingsProvider.removeObserver(self)
	}
}

// MARK: - ColumnsViewOutput
extension ColumnPresenter: ColumnViewOutput {

	func configure(for id: UUID) {
		interactor?.configure(for: id)
	}

	func viewDidChange(state: ViewState) {
		guard state == .didLoad else {
			return
		}
		interactor?.fetchData()
	}

	func userClickedOnPlusButton() {

		let target = view?.selection.first

		guard let id = interactor?.newItem(
			localization.newItemText,
			isStrikethrough: false,
			note: nil,
			iconName: nil,
			tintColor: nil,
			target: target
		) else {
			return
		}

		if let target {
			view?.expand([target])
		}
		view?.scroll(to: id)
		view?.focus(on: id, key: "title")
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
		let itemModel = factory.makeItem(item: item, isLeaf: true, iconColor: settingsProvider.state.iconColor)
		let model = ColumnModel(title: item.text, configuration: itemModel.configuration)
		view?.display(model)
	}
}

// MARK: - Helpers
private extension ColumnPresenter {

	func editItem() {
		guard let item = interactor?.rootItem()?.value else {
			return
		}
		let details = ItemDetailsView.Properties(
			text: item.text,
			description: item.note ?? "",
			icon: item.iconName
		)
		let model = ItemDetailsView.Model(
			navigationTitle: localization.editItemDetailsTitle,
			properties: details
		)
		router.showDetails(with: model) { [weak self] saved in
			let note = saved.description.isEmpty ? nil : saved.description
			self?.interactor?.set(
				saved.text,
				note: note,
				iconName: saved.icon,
				tintColor: saved.tintColor
			)
		}
	}
}
