//
//  FeatureProvider.swift
//  Nested List
//
//  Created by Anton Cherkasov on 20.09.2026.
//

import CorePresentation

/// Provides the availability of macOS-specific features.
///
/// Experimental features are enabled for Debug builds and disabled for Release
/// builds until they are ready for production use.
@MainActor public final class FeatureProvider {

	/// Creates a feature provider for the current macOS build.
	public init() { }
}

// MARK: - FeatureProvidable
extension FeatureProvider: FeatureProvidable {

	/// Returns whether a macOS feature is available in the current build.
	public func isAvailable(_ feature: Feature) -> Bool {
		switch feature {
		case .columns:
			#if DEBUG
			true
			#else
			false
			#endif
		}
	}
}
