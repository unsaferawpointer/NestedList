//
//  InfoProviderMock.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 07.05.2026.
//

import Foundation
import CoreModule
import CorePresentation

struct InfoProviderMock {
	let version: Version?
	let bundleID: String? = nil
}

// MARK: - InfoProvider
extension InfoProviderMock: InfoProvider { }
