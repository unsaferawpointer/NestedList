//
//  ListAnimator.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Foundation
import Hierarchy

enum ListAnimation<ID> {
	case remove(offset: Int, parent: ID?)
	case insert(offset: Int, parent: ID?)
	case reload(id: ID?)
}

final class ListAnimator<Model: Identifiable> {

	func calculate(old: Snapshot<Model>, new: Snapshot<Model>) -> (deleted: Set<Model.ID>, inserted: Set<Model.ID>) {
		return (deleted: old.identifiers.subtracting(new.identifiers),
				inserted: new.identifiers.subtracting(old.identifiers))
	}

	func calculate(
		old: Snapshot<Model>,
		new: Snapshot<Model>,
		animate: @escaping (ListAnimation<Model.ID>) -> Void
	) {

		calculate(in: nil, animate: animate) { parent in
			guard let parent else {
				return (old: old.root, new: new.root)
			}
			return (
				old: old.hierarchy[unsafe: parent],
				new: new.hierarchy[unsafe: parent]
			)
		}
	}

	func calculate(
		in parent: Model.ID?,
		animate: @escaping (ListAnimation<Model.ID>) -> Void,
		next: (Model.ID?) -> (old: [Model.ID], new: [Model.ID])
	) {

		var oldState = next(parent).old
		let newState = next(parent).new

		let difference = newState.difference(from: oldState)

		if !difference.isEmpty {
			animate(.reload(id: parent))
		}

		var removed = Set<Model.ID>()

		for change in difference {
			switch change {
			case let .remove(oldOffset, id, _):
				animate(.remove(offset: oldOffset, parent: parent))
				removed.insert(id)
			case let .insert(newOffset, id, _):
				animate(.insert(offset: newOffset, parent: parent))
				removed.remove(id)
			}
		}

		oldState.removeAll { removed.contains($0) }
		oldState.forEach { parent in
			calculate(in: parent, animate: animate, next: next)
		}
	}
}

