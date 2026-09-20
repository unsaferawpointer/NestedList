//
//  FeatureProvidable.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 20.09.2026.
//

/// Provides the availability of features for a specific application target.
///
/// Each platform can define its own feature type and decide independently
/// which features are available in a particular build configuration.
@MainActor public protocol FeatureProvidable<Flag> {

	/// The feature type supported by the provider.
	associatedtype Flag

	/// Returns whether the specified feature is available.
	///
	/// - Parameter feature: The feature whose availability should be checked.
	/// - Returns: `true` when the feature can be used in the current build.
	func isAvailable(_ feature: Flag) -> Bool
}
