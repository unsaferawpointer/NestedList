//
//  ListAnimator.swift
//  iOS
//
//  Created by Anton Cherkasov on 11.05.2025.
//

import Foundation
import DesignSystem
import Hierarchy

final class ListAnimator { }

extension ListAnimator {

	static func update<M: CellModel>(oldState: ListState<M>, newState: ListState<M>, delegate: any CacheDelegate<M>) {

		let oldList = oldState.flattened
		let newList = newState.flattened

		let intersection = Set(oldList).intersection(newList)

		for id in intersection {

			let oldModel = oldState.model(for: id)
			let newModel = newState.model(for: id)

			let oldConfiguration = oldState.configuration(for: id)
			let newConfiguration = newState.configuration(for: id)

			guard let oldIndex = oldList.firstIndex(where: { $0 == id }) else {
				continue
			}
			let oldIndexPath = IndexPath(row: oldIndex, section: 0)

			if oldModel != newModel {
				delegate.updateCell(indexPath: oldIndexPath, model: newModel)
			}

			if oldConfiguration != newConfiguration {
				delegate.updateCell(indexPath: oldIndexPath, rowConfiguration: newConfiguration)
			}
		}
	}

	static func animate<M: CellModel>(oldState: ListState<M>, newState: ListState<M>, delegate: any CacheDelegate) {

		let oldList = oldState.flattened
		let newList = newState.flattened

		let diff = newList.difference(from: oldList)

		let removed = diff.compactMap { operation -> IndexPath? in
			guard case let .remove(offset, _, _) = operation else {
				return nil
			}
			return IndexPath(row: offset, section: 0)
		}

		let inserted = diff.compactMap { operation -> IndexPath? in
			guard case let .insert(offset, _, _) = operation else {
				return nil
			}
			return IndexPath(row: offset, section: 0)
		}

		guard removed.isEmpty == false || inserted.isEmpty == false else {
			return
		}

		// MARK: - Start
		delegate.beginUpdates()
		delegate.update(deleteRows: removed, insertRows: inserted)
		delegate.endUpdates()
		// MARK: - End
	}
}
