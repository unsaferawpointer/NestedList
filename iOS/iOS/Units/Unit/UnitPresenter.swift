//
//  UnitPresenter.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import Foundation
import Hierarchy
import UIKit
import CoreModule
import DesignSystem

protocol UnitPresenterProtocol: AnyObject {
	func present(_ content: Content)
}

final class UnitPresenter {

	var interactor: UnitInteractorProtocol?

	weak var view: UnitView?

	private(set) var factory: ItemsFactoryProtocol = ItemsFactory()
}

// MARK: - UnitPresenterProtocol
extension UnitPresenter: UnitPresenterProtocol {

	func present(_ content: Content) {

		var snapshot = Snapshot(content.root.nodes)
		snapshot.validate(keyPath: \.isDone)
		snapshot.validate(keyPath: \.isMarked)

		let converted = snapshot
			.map { info in
				factory.makeItem(
					item: info.model,
					level: info.level
				)
			}
		view?.display(converted)
	}
}

extension UnitPresenter: UnitViewDelegate {

	func userTappedCreateButton() {
		let model = DetailsView.Model(title: "")
		view?.showDetails(with: model) { [weak self] saved, success in
			self?.view?.hideDetails()
			if success {
				let note = saved.description.isEmpty ? nil : saved.description
				self?.interactor?.newItem(
					saved.title,
					note: note,
					isMarked: saved.isMarked,
					style: saved.style,
					target: nil
				)
			}
		}
	}
	
	func userTappedEditButton(id: UUID) {
		guard let item = interactor?.item(for: id) else {
			return
		}
		let model = item.details
		view?.showDetails(with: model) { [weak self] saved, success in
			self?.view?.hideDetails()
			if success {
				let note = saved.description.isEmpty ? nil : saved.description
				self?.interactor?.set(saved.title, note: note, isMarked: saved.isMarked, style: saved.style, for: id)
			}
		}
	}
	
	func userTappedDeleteButton(ids: [UUID]) {
		interactor?.deleteItems(ids)
	}
	
	func userTappedAddButton(target: UUID) {
		let model = DetailsView.Model(title: "")
		view?.showDetails(with: model) { [weak self] saved, success in
			self?.view?.hideDetails()
			if success {
				let note = saved.description.isEmpty ? nil : saved.description
				self?.interactor?.newItem(
					saved.title,
					note: note,
					isMarked: saved.isMarked,
					style: saved.style,
					target: target
				)
				self?.view?.expand(target)
			}
		}
	}

	func userSetStatus(isDone: Bool, id: UUID) {
		interactor?.setStatus(isDone, for: id)
	}

	func userMark(isMarked: Bool, id: UUID) {
		interactor?.mark(isMarked, id: id)
	}

	func userSetStyle(style: Item.Style, id: UUID) {
		interactor?.setStyle(style, for: id)
	}

	func userTappedCutButton(ids: [UUID]) {
		guard let first = ids.first, let interactor else {
			return
		}
		let string = interactor.string(for: first)

		UIPasteboard.general.string = string

		interactor.deleteItems(ids)
	}

	func userTappedCopyButton(ids: [UUID]) {
		guard let first = ids.first, let interactor else {
			return
		}
		let string = interactor.string(for: first)

		UIPasteboard.general.string = string
	}

	func userTappedPasteButton(target: UUID) {
		guard let string = UIPasteboard.general.string else {
			return
		}
		interactor?.insertStrings([string], to: .onItem(with: target))
	}

	func updateView() {
		interactor?.fetchData()
	}
}

// MARK: - DropDelegate
extension UnitPresenter: DropDelegate {

	typealias ID = UUID

	func move(_ id: UUID, to destination: Destination<UUID>) {
		interactor?.move(id: id, to: destination)
	}

	func canMove(_ id: UUID) -> Bool {
		return true
	}

	func validateMovement(_ id: UUID, to destination: Destination<UUID>) -> Bool {
		interactor?.validateMovement(id, to: destination) ?? false
	}
}

private extension Item {

	var details: DetailsView.Model {
		return .init(
			title: text,
			description: note ?? "",
			isMarked: isMarked,
			style: style
		)
	}
}
