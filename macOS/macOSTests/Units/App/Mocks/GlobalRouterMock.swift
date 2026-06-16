//
//  GlobalRouterMock.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 07.05.2026.
//

import Foundation
import CoreModule
@testable import Nested_List

final class GlobalRouterMock {

	private(set) var invocations: [Action] = []
	private let openPanelURL: URL?

	init(openPanelURL: URL? = nil) {
		self.openPanelURL = openPanelURL
	}
}

// MARK: - GlobalRouterProtocol
extension GlobalRouterMock: GlobalRouterProtocol {

	func showOnboarding(for version: Version) {
		invocations.append(.showOnboarding(version: version))
	}

	func showPreferences() {
		invocations.append(.showPreferences)
	}

	func showOpenPanel(completionHandler: @escaping (URL) -> Void) {
		invocations.append(.showOpenPanel)
		if let openPanelURL {
			completionHandler(openPanelURL)
		}
	}
}

// MARK: - Nested Data Structs
extension GlobalRouterMock {

	enum Action: Equatable {
		case showOnboarding(version: Version)
		case showPreferences
		case showOpenPanel
	}
}
