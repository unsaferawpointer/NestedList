//
//  DocumentAssembly.swift
//  Nested List
//
//  Created by Anton Cherkasov on 25.08.2025.
//

import Cocoa
import CoreModule
import CorePresentation

final class DocumentAssembly {

	@MainActor
	static func build(storage: DocumentStorage<DocumentContent>, featureProvider: any FeatureProvidable<Feature>) -> NSViewController {
		switch storage.state.view {
		case .list, .unknown:
			ContentUnitAssembly.build(storage: storage)
		case .columns:
			featureProvider.isAvailable(.columns)
				? ColumnsUnitAssembly.build(storage: storage)
				: ContentUnitAssembly.build(storage: storage)
		}
	}
}
