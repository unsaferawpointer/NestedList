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

	var localization: ColumnLocalizationProtocol

	private(set) var settingsProvider: any StateProviderProtocol<Settings>

	private let factory: ItemsFactoryProtocol

	// MARK: - Initialization

	init(
		settingsProvider: any StateProviderProtocol<Settings> = SettingsProvider.shared,
		localization: ColumnLocalizationProtocol = ColumnLocalization(),
		factory: ItemsFactoryProtocol = ItemsFactory()
	) {
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
			isMarked: false,
			style: .item,
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
		let itemModel = factory.makeItem(item: item, level: 0, iconColor: settingsProvider.state.iconColor)
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
			isStrikethrough: item.isStrikethrough,
			isMarked: item.isMarked,
			isSection: item.style != .item,
			icon: item.style.icon
		)
		let model = ItemDetailsView.Model(
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
