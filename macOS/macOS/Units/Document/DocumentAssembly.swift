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
	static func build(storage: DocumentStorage<Content>) -> NSViewController {
		ContentUnitAssembly.build(
			storage: storage,
			configuration: .init(drawsBackground: true, hasInsets: true)
		)
	}
}
