//
//  Collection+Extension.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Foundation

extension Collection {

	func firstIndex<T: Equatable>(where keyPath: KeyPath<Element, T>, equalsTo value: T) -> Index? {
		return firstIndex { element in
			element[keyPath: keyPath] == value
		}
	}

	subscript(optional index: Index) -> Element? {
		guard indices.contains(index) else {
			return nil
		}
		return self[index]
	}
}
