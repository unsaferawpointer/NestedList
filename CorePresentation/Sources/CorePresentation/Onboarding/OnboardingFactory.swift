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

	static func build(for version: Version, in bundle: Bundle) throws -> [Feature]? {
		guard
			let path = resourceURL(for: version, in: bundle),
			let data = try? Data(contentsOf: path)
		else {
			return nil
		}

		let features = try JSONDecoder().decode([Feature].self, from: data)
		return filter(features: features, for: version)
	}
}

// MARK: - Helpers
private extension OnboardingFactory {

	static func resourceURL(for version: Version, in bundle: Bundle) -> URL? {
		return bundle.url(forResource: "onboarding", withExtension: "json")
	}

	static func filter(features: [Feature], for version: Version) -> [Feature] {
		return features.filter { feature in
			isSupported(feature: feature, for: version)
		}
	}

	static func isSupported(feature: Feature, for version: Version) -> Bool {
		if let minVersion = feature.minVersion, let min = Version(rawValue: minVersion), version < min {
			return false
		}
		if let maxVersion = feature.maxVersion, let max = Version(rawValue: maxVersion), version > max {
			return false
		}
		return true
	}
}
