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

	private var observations = [ObjectIdentifier: (State) -> Void]()

	public var state: State {
		didSet {
			guard state != oldValue else {
				return
			}

			defaults.setValuesForKeys(
				[
					CompletionBehavior.key: state.completionBehaviour.rawValue,
					IconColor.key: state.iconColor.rawValue,
					OnboardingVersion.key: state.lastOnboardingVersion?.rawValue
				]
			)

			observations.values.forEach {
				$0(state)
			}
		}
	}

	// MARK: DI

	private let defaults = UserDefaults.standard

	// MARK: - Initialization

	public init() {

		let completionBehaviour = defaults.getProperty(as: CompletionBehavior.self) ?? CompletionBehavior.defaultValue
		let iconColor = defaults.getProperty(as: IconColor.self) ?? IconColor.defaultValue
		let lastOnboardingVersion = defaults.getProperty(as: OnboardingVersion.self)

		self.state = Settings(
			completionBehaviour: completionBehaviour ?? .regular,
			iconColor: iconColor ?? .accent,
			lastOnboardingVersion: lastOnboardingVersion
		)

		defaults.register(
			defaults:
				[
					CompletionBehavior.key: CompletionBehavior.defaultValue?.rawValue,
					IconColor.key: IconColor.defaultValue?.rawValue
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
		let iconColor = defaults.getProperty(as: IconColor.self) ?? IconColor.defaultValue
		let lastOnboardingVersion = defaults.getProperty(as: OnboardingVersion.self)

		let current = Settings(
			completionBehaviour: completionBehaviour ?? .regular,
			iconColor: iconColor ?? .accent,
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

	public func addObservation<O>(for object: O, handler: @escaping (Settings) -> Void) where O : AnyObject {
		handler(state)

		observations[ObjectIdentifier(object)] = { value in
			handler(value)
		}
	}
	
	public func removeObserver(_ object: AnyObject) {
		observations[ObjectIdentifier(object)] = nil
	}

	public func modificate(_ block: (inout State) -> Void) {
		block(&state)
	}
}
