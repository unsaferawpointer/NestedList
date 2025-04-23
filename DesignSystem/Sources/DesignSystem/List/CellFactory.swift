//
//  CellFactory.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 23.04.2025.
//

import AppKit

final class CellFactory { }

extension CellFactory {

	static func makeCellIfNeeded<Model: CellModel>(
		for model: Model,
		in table: NSTableView?,
		delegate: (any CellDelegate<Model>)?
	) -> NSView? {

		typealias Cell = Model.Cell

		let id = NSUserInterfaceItemIdentifier(Cell.reuseIdentifier)
		var view = table?.makeView(withIdentifier: id, owner: self) as? Cell
		if view == nil {
			view = Cell(model)
			view?.identifier = id
			view?.delegate = delegate
			return view
		}
		view?.model = model
		view?.delegate = delegate
		return view
	}

	static func configureCell<T: CellModel>(with model: T, at row: Int, in table: NSTableView?) {
		let cell = table?.view(atColumn: 0, row: row, makeIfNecessary: false) as? T.Cell
		cell?.model = model
	}
}
