//
//  DocumentAssembly.swift
//  Nested List
//
//  Created by Anton Cherkasov on 25.08.2025.
//

import Cocoa
import CoreModule

final class DocumentAssembly {

	@MainActor
	static func build(storage: DocumentStorage<DocumentContent>) -> NSViewController {
		switch storage.state.view {
		case .list:
			ContentUnitAssembly.build(storage: storage)
		case .columns:
			ColumnsUnitAssembly.build(storage: storage)
		}
	}
}
