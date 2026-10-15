//
//  NavigationResolver.swift
//  Nested List
//
//  Created by Anton Cherkasov on 18.10.2026.
//

import Foundation
import CoreModule

final class NavigationResolver {

	var path: NavigationPath

	// MARK: - Initialization

	init(path: NavigationPath = .init(root: nil)) {
		self.path = path
	}
}

// MARK: - Public Interface
extension NavigationResolver {

	func items(in content: DocumentContent) -> [Item?] {
		let items: [UUID?] = [path.root] + path.suffix
		return items.map { id in
			guard let id else {
				return nil
			}
			return content[id]
		}
	}

	func focus(on id: UUID, in content: DocumentContent) throws(NavigationError) {
		guard content[id] != nil else {
			throw .targetNotFound
		}
		if let root = path.root, content[root] == nil {
			throw .rootNotFound
		}

		let ancestorIDs = ancestorIDs(for: id, in: content)
		guard let root = path.root else {
			path = NavigationPath(root: nil, suffix: ancestorIDs)
			return
		}
		guard let rootIndex = ancestorIDs.firstIndex(of: root) else {
			throw .targetOutsideRoot
		}
		path = NavigationPath(root: root, suffix: Array(ancestorIDs.dropFirst(rootIndex + 1)))
	}

	var focused: UUID? {
		path.focused ?? path.root
	}

	// A -> B -> C -> D
	// A -> B
	//
	func resolve(content: DocumentContent) throws(NavigationError) {
		var intersection: [UUID] = []
		if let root = path.root, content[root] == nil {
			throw .rootNotFound
		}
		for (index, id) in path.suffix.enumerated() {
			let previous = if index == 0 {
				path.root
			} else {
				path.suffix[index - 1]
			}
			guard content[id] != nil, content.parent(for: id) == previous else {
				break
			}
			intersection.append(id)
		}
		path = NavigationPath(root: path.root, suffix: intersection)
	}
}

// MARK: - Private
private extension NavigationResolver {

	func ancestorIDs(for id: UUID, in content: DocumentContent) -> [UUID] {
		var ancestorIDs = [id]
		var current = id

		while let parent = content.parent(for: current) {
			ancestorIDs.append(parent)
			current = parent
		}
		return ancestorIDs.reversed()
	}
}

// MARK: - NavigationError
extension NavigationResolver {

	enum NavigationError: Error, Equatable {
		case rootNotFound
		case targetNotFound
		case targetOutsideRoot
	}
}
