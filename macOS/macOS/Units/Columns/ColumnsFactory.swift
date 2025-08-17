//
//  ColumnsFactory.swift
//  Nested List
//
//  Created by Anton Cherkasov on 15.08.2025.
//

import AppKit
import CoreModule

final class ColumnsFactory {

	private let storage: DocumentStorage<Content>

	init(storage: DocumentStorage<Content>) {
		self.storage = storage
	}
}

extension ColumnsFactory {

	func build(for id: UUID) -> NSCollectionViewItem {
		return ColumnUnitAssembly.build(root: id, storage: storage)
	}
}
