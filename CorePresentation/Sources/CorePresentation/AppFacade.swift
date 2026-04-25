//
//  AppFacade.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 25.04.2026.
//

import Foundation
import CoreModule

public struct AppFacade { }

extension AppFacade {

	static let versionKey: String = "CFBundleShortVersionString"
}

public extension AppFacade {

	static func version() -> Version? {
		let rawValue = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		guard let rawValue, let result = Version(rawValue: rawValue) else {
			return nil
		}
		return result
	}
}
