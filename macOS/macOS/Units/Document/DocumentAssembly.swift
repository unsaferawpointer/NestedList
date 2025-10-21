//
//  DocumentAssembly.swift
//  Nested List
//
//  Created by Anton Cherkasov on 25.08.2025.
//

import Cocoa
import CoreModule

final class DocumentAssembly {

	static func build(storage: DocumentStorage<Content>, for view: Content.ContentView) -> NSViewController {
		switch view {
		case .list:
			ContentUnitAssembly.build(
				storage: storage,
				configuration: .init(drawsBackground: true, hasInsets: true)
			)
		case .board:
			ColumnsUnitAssembly.build(
				storage: storage
			)
		}
	}
}
