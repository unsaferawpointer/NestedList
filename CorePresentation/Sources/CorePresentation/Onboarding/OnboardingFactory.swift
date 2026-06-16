//
//  OnboardingFactory.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 12.05.2026.
//

import Foundation
import CoreModule
import DesignSystem

public final class OnboardingFactory { }

// MARK: - Public Interface
public extension OnboardingFactory {

	static func build(for version: Version, lastVersion: Version? = nil, in bundle: Bundle) throws -> [Feature]? {
		guard
			let path = resourceURL(for: version, in: bundle),
			let data = try? Data(contentsOf: path)
		else {
			return nil
		}

		let features = try JSONDecoder().decode([Feature].self, from: data)
		return filter(features: features, for: version, lastVersion: lastVersion)
	}
}

// MARK: - Helpers
private extension OnboardingFactory {

	static func resourceURL(for version: Version, in bundle: Bundle) -> URL? {
		return bundle.url(forResource: "onboarding", withExtension: "json")
	}

	static func filter(features: [Feature], for version: Version, lastVersion: Version?) -> [Feature] {
		return features.filter { feature in
			isSupported(feature: feature, for: version, lastVersion: lastVersion)
		}
	}

	static func isSupported(feature: Feature, for version: Version, lastVersion: Version?) -> Bool {
		guard let lastVersion else {
			return feature.minVersion == nil
		}
		guard let rawMinVersion = feature.minVersion, let minVersion = Version(rawValue: rawMinVersion) else {
			return false
		}
		if version < minVersion || lastVersion >= minVersion {
			return false
		}
		if let rawMaxVersion = feature.maxVersion,
		   let maxVersion = Version(rawValue: rawMaxVersion), version > maxVersion {
			return false
		}
		return true
	}
}
