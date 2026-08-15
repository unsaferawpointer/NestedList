//
//  ColumnsInteractor.swift
//  macOS
//

import Foundation
import CoreModule

@MainActor
protocol ColumnsInteractorProtocol: AnyObject {
	func fetchData()
	func createNewItem(with text: String) -> UUID
}

/// The Columns interactor.
@MainActor
final class ColumnsInteractor {

	private let storage: DocumentStorage<DocumentContent>

	weak var presenter: (any ColumnsPresenterProtocol)?

	private let base: any CommonInteractorProtocol

	// MARK: - Initialization

	init(storage: DocumentStorage<DocumentContent>) {
		self.storage = storage
		self.base = CommonInteractor(storage: storage)
		storage.addObservation(for: self) { [weak self] content in
			self?.presenter?.present(content.snapshot().root)
		}
	}

	deinit {
		storage.removeObserver(self)
	}
}

// MARK: - ColumnsInteractorProtocol
extension ColumnsInteractor: ColumnsInteractorProtocol {

	func fetchData() {
		presenter?.present(storage.state.snapshot().root)
	}

	func createNewItem(with text: String) -> UUID {
		let properties = ItemProperties(text: text)
		return base.newItem(with: properties, target: nil)
	}
}
