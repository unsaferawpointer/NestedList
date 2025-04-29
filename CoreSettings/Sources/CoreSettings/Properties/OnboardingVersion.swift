//
//  OnboardingVersion.swift
//  CoreSettings
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import Foundation
import CoreModule

public struct OnboardingVersion {

	public var rawValue: String

	public init?(rawValue: String) {
		self.rawValue = rawValue
	}
}

extension OnboardingVersion {

	var version: Version? {
		return Version(rawValue: rawValue)
	}
}

// MARK: - Hashable
extension OnboardingVersion: Hashable { }

// MARK: - SettingsProperty
extension OnboardingVersion: SettingsProperty {

	static var key: String {
		"onboarding_version"
	}
}
