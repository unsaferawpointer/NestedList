//
//  ColumnsFactory.swift
//  macOS
//

import AppKit
import CoreModule

/// Factory that builds column collection items for the Columns unit.
final class ColumnsFactory {

	private let storage: DocumentStorage<DocumentContent>

	init(storage: DocumentStorage<DocumentContent>) {
		self.storage = storage
	}
}

// MARK: - Public Interface
extension ColumnsFactory {

	@MainActor
	func build(for id: UUID) -> NSCollectionViewItem {
		return ColumnUnitAssembly.build(root: id, storage: storage)
	}
}
