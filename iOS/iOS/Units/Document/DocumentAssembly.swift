//
//  DocumentAssembly.swift
//  iOS
//

import UIKit
import CoreModule

@MainActor
final class DocumentAssembly {

	static func build(storage: DocumentStorage<DocumentContent>) -> UIViewController {
		switch storage.state.view {
		case .list, .unknown:
			ContentUnitAssembly.build(router: nil, storage: storage)
		case .columns:
			ColumnsUnitAssembly.build()
		}
	}
}
