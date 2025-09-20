//
//  DocumentPresenter.swift
//  iOS
//
//  Created by Anton Cherkasov on 14.09.2025.
//

import Foundation

import CoreModule
import DesignSystem

protocol DocumentPresenterProtocol: AnyObject {
	func present(type: Content.ContentView)
}

final class DocumentPresenter {

	// MARK: - DI by Property

	weak var view: DocumentView?

	var interactor: DocumentInteractorProtocol?

}

// MARK: - DocumentPresenterProtocol
extension DocumentPresenter: DocumentPresenterProtocol {

	func present(type: Content.ContentView) {
		view?.showDocument(type: type)
	}
}

// MARK: - DocumentViewDelegate
extension DocumentPresenter: DocumentViewDelegate {

	func viewDidChange(state: ViewState) {
		guard .didLoad == state else {
			return
		}
		interactor?.fetchData()
	}
}
