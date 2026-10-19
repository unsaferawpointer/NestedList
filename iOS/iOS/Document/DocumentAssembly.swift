//
//  DocumentAssembly.swift
//  iOS
//

import UIKit
import CoreModule

@MainActor
final class DocumentAssembly {

	static func build(storage: DocumentStorage<DocumentContent>) -> UIViewController {
		ContentUnitAssembly.build(router: nil, storage: storage)
	}
}
