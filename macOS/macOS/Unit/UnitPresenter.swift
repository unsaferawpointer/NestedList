//
//  UnitPresenter.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import CoreModule
import Hierarchy

protocol UnitPresenterProtocol: AnyObject {
	func present(_ content: Content)
}

final class UnitPresenter {

	var interactor: UnitInteractorProtocol?

	weak var view: UnitView?
}

// MARK: - UnitPresenterProtocol
extension UnitPresenter: UnitPresenterProtocol {

	func present(_ content: Content) {
		let snapshot = Snapshot(content.nodes)
			.map { item in
				ItemModel(
					id: item.id,
					value: .init(
						isOn: item.isDone,
						text: item.text
					),
					configuration: .init(textColor: .labelColor)
				)
			}
		view?.display(snapshot)
	}
}

// MARK: - UnitViewOutput
extension UnitPresenter: UnitViewOutput {

	func viewDidLoad() {
		interactor?.fetchData()
	}
}
