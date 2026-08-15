//
//  ColumnPresenter.swift
//  macOS
//

import Foundation
import CoreModule
import DesignSystem
import CorePresentation

/// The Column presenter interface.
protocol ColumnPresenterProtocol: AnyObject {
	func present(_ item: Item)
}

/// The Column view output interface.
protocol ColumnViewOutput: ViewDelegate, MenuDelegate<ColumnMenuIdentifier> {
	func configure(for id: UUID)
}

final class ColumnPresenter {

	// MARK: - DI

	var interactor: ColumnInteractorProtocol?

	weak var view: ColumnUnitView?

	var router: ContentRouterProtocol

	var localization: ColumnLocalizationProtocol

	private(set) var settingsProvider: any StateProviderProtocol<Settings>

	private let factory: ItemsFactoryProtocol

	// MARK: - Initialization

	init(
		router: ContentRouterProtocol,
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
}

// MARK: - MenuDelegate
extension ColumnPresenter: MenuDelegate {

	func menuItemClicked(_ item: ColumnMenuIdentifier, source: MenuSource) {
		switch item {
		case .columnNew:
			fatalError()
		case .columnEdit:
			fatalError()
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

	func validateMenuItem(_ item: ColumnMenuIdentifier) -> Bool {
		switch item {
		case .moveForward:
			interactor?.validateMovingForward() ?? false
		case .moveBackward:
			interactor?.validateMovingBackward() ?? false
		default:
			true
		}
	}

	func isHidden(_ item: ColumnMenuIdentifier) -> Bool {
		return false
	}

	func stateForMenuItem(_ item: ColumnMenuIdentifier) -> ControlState {
		return .off
	}

	func menuItems() -> [ColumnMenuIdentifier] {
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
