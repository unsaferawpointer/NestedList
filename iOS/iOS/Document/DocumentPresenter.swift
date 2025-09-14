//
//  DocumentPresenter.swift
//  iOS
//
//  Created by Anton Cherkasov on 14.09.2025.
//

import Foundation

protocol DocumentPresenterProtocol: AnyObject { }

final class DocumentPresenter {

	// MARK: - DI by Property

	weak var view: DocumentView?

	var interactor: DocumentInteractorProtocol?

}

// MARK: - DocumentPresenterProtocol
extension DocumentPresenter: DocumentPresenterProtocol { }

// MARK: - DocumentViewDelegate
extension DocumentPresenter: DocumentViewDelegate { }
