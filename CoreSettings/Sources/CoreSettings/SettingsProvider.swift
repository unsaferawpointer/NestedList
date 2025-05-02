//
//  SettingsProvider.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 10.03.2025.
//

import Foundation
import CoreModule

private extension UserDefaults {

	func getProperty<P: SettingsProperty>(as type: P.Type) -> P? where P.RawValue == Int {
		let rawValue = integer(forKey: P.key)
		return P(rawValue: rawValue)
	}

	func getProperty<P: SettingsProperty>(as type: P.Type) -> P? where P.RawValue == String {
		guard let rawValue = string(forKey: P.key) else {
			return nil
		}
		return P(rawValue: rawValue)
	}

	func setProperty<P: SettingsProperty>(_ property: P) where P.RawValue == Int {
		setValue(property.rawValue, forKey: P.key)
	}

	func setProperty<P: SettingsProperty>(_ property: P) where P.RawValue == String {
		setValue(property.rawValue, forKey: P.key)
	}
}

public final class SettingsProvider {

	nonisolated(unsafe) public static var shared = SettingsProvider()

	public typealias State = Settings

	private var observations = [(State) -> Bool]()

	public var state: State {
		didSet {
			guard state != oldValue else {
				return
			}

			defaults.setValuesForKeys(
				[
					CompletionBehavior.key: state.completionBehaviour.rawValue,
					MarkingBehavior.key: state.markingBehaviour.rawValue,
					IconColor.key: state.iconColor.rawValue,
					OnboardingVersion.key: state.lastOnboardingVersion?.rawValue
				]
			)

			observations = observations.filter { $0(state) }
		}
	}

	// MARK: DI

	private let defaults = UserDefaults.standard

	// MARK: - Initialization

	public init() {

		let completionBehaviour = defaults.getProperty(as: CompletionBehavior.self)
		let markingBehaviour = defaults.getProperty(as: MarkingBehavior.self)
		let iconColor = defaults.getProperty(as: IconColor.self)
		let lastOnboardingVersion = defaults.getProperty(as: OnboardingVersion.self)

		self.state = Settings(
			completionBehaviour: completionBehaviour ?? .regular,
			markingBehaviour: markingBehaviour ?? .regular,
			iconColor: iconColor ?? .neutral,
			lastOnboardingVersion: lastOnboardingVersion
		)

		defaults.register(
			defaults:
				[
					CompletionBehavior.key: CompletionBehavior.regular.rawValue,
					MarkingBehavior.key: MarkingBehavior.regular.rawValue,
					IconColor.key: IconColor.neutral.rawValue
				]
		)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(userDefaultsDidChange),
			name: UserDefaults.didChangeNotification,
			object: nil
		)
	}
}

extension SettingsProvider {

	@objc
	func userDefaultsDidChange(_ notification: Notification) {
		// Реакция на изменение настроек
		let completionBehaviour = defaults.getProperty(as: CompletionBehavior.self)
		let markingBehaviour = defaults.getProperty(as: MarkingBehavior.self)
		let iconColor = defaults.getProperty(as: IconColor.self)
		let lastOnboardingVersion = defaults.getProperty(as: OnboardingVersion.self)

		let current = Settings(
			completionBehaviour: completionBehaviour ?? .regular,
			markingBehaviour: markingBehaviour ?? .regular,
			iconColor: iconColor ?? .neutral,
			lastOnboardingVersion: lastOnboardingVersion
		)

		guard current != state else {
			return
		}
		self.state = current
	}
}


// MARK: - StateProviderProtocol
extension SettingsProvider: StateProviderProtocol {

	public func modificate(_ block: (inout State) -> Void) {
		block(&state)
	}

	public func addObservation<O: AnyObject>(
		for object: O,
		handler: @escaping (O, State) -> Void
	) {
		handler(object, state)

		observations.append { [weak object] value in
			guard let object = object else {
				return false
			}

			handler(object, value)
			return true
		}
	}
}
