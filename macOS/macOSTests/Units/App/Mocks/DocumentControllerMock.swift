//
//  DocumentControllerMock.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 07.05.2026.
//

import Foundation
import UniformTypeIdentifiers
@testable import Nested_List

final class DocumentControllerMock {

	private(set) var invocations: [(url: URL, type: UTType)] = []
}

// MARK: - DocumentControllerProtocol
extension DocumentControllerMock: DocumentControllerProtocol {

	func loadFile(at url: URL, with type: UTType) {
		invocations.append((url: url, type: type))
	}
}
