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
protocol ColumnViewOutput: ViewDelegate {
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

// MARK: - ColumnsPresenterProtocol
extension ColumnPresenter: ColumnPresenterProtocol {

	func present(_ item: Item) {
		let itemModel = factory.makeItem(item: item, isLeaf: true, iconColor: settingsProvider.state.iconColor)
		let model = ColumnModel(title: item.text, configuration: itemModel.configuration)
		view?.display(model)
	}
}
