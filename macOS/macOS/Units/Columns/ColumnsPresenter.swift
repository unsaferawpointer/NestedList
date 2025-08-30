//
//  ColumnsPresenter.swift
//  Nested List
//
//  Created by Anton Cherkasov on 14.08.2025.
//

import Hierarchy
import CoreModule
import DesignSystem

protocol ColumnsPresenterProtocol: AnyObject {
	func present(_ nodes: [Node<Item>])
}

final class ColumnsPresenter {

	// MARK: - DI by init

	private let localization: ColumnsLocalizationProtocol

	// MARK: - DI by property

	var interactor: ColumnsInteractorProtocol?

	weak var view: ColumnsUnitView?

	// MARK: - Initialization

	init(localization: ColumnsLocalizationProtocol = ColumnsLocalization()) {
		self.localization = localization
	}
}

// MARK: - ViewDelegate
extension ColumnsPresenter: ViewDelegate {

	func viewDidChange(state: ViewState) {
		guard state == .didLoad else {
			return
		}
		interactor?.fetchData()
	}
}

// MARK: - ColumnsViewOutput
extension ColumnsPresenter: ColumnsViewOutput {

	func handleNewColumnClick() {
		_ = interactor?.createNewItem(with: localization.newItemText)
	}
}

// MARK: - ColumnsPresenterProtocol
extension ColumnsPresenter: ColumnsPresenterProtocol {

	func present(_ nodes: [Node<Item>]) {
		let ids = nodes.map(\.id)
		guard !ids.isEmpty else {
			let placeholderModel: PlaceholderModel = .init(
				icon: "rectangle.split.3x1",
				title: localization.placeholderTitle,
				subtitle: localization.placeholderDescription
			)
			view?.display(state: .placeholder(model: placeholderModel))
			return
		}
		view?.display(state: .columns(ids: ids))
	}
}
