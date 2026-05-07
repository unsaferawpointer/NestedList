//
//  AppInfo.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 25.04.2026.
//

import Foundation
import CoreModule

public protocol InfoProvider {
	var version: Version? { get }
	var bundleID: String? { get }
}

public final class AppInfo {

	public init() { }
}

// MARK: - InfoProvider
extension AppInfo: InfoProvider {

	public var version: Version? {
		let rawValue = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		guard let rawValue, let result = Version(rawValue: rawValue) else {
			return nil
		}
		return result
	}

	public var bundleID: String? {
		return Bundle.main.bundleIdentifier
	}
}
