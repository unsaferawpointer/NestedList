//
//  SettingsProvider.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 10.03.2025.
//

import Foundation

private extension UserDefaults {

	func getProperty<P: SettingsProperty>(as type: P.Type) -> P? where P.RawValue == Int {
		let rawValue = integer(forKey: P.key)
		return P(rawValue: rawValue)
	}

	func setProperty<P: SettingsProperty>(_ property: P) where P.RawValue == Int {
		setValue(property.rawValue, forKey: P.key)
	}

	func getObject<T: RawRepresentable>(forKey key: String, as type: T.Type) -> T? where T.RawValue == Int {
		let rawValue = self.integer(forKey: key)
		return T(rawValue: rawValue)
	}

	func setObject<T: RawRepresentable>(_ object: T, forKey key: String) where T.RawValue == Int {
		setValue(object.rawValue, forKey: key)
	}

}

public final class SettingsProvider {

	public static var shared = SettingsProvider()

	public typealias State = Settings

	private var observations = [(State) -> Bool]()

	public var state: State {
		didSet {
			guard state != oldValue else {
				return
			}
			defaults.set(state.completionBehaviour.rawValue, forKey: "completion_behaviour")
			observations = observations.filter { $0(state) }
		}
	}

	// MARK: DI

	private let defaults = UserDefaults.standard

	// MARK: - Initialization

	public init() {
		let completionBehaviour = defaults.getProperty(as: CompletionBehaviour.self)
		self.state = Settings(completionBehaviour: completionBehaviour ?? .regular)

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
		let completionBehaviour = defaults.getProperty(as: CompletionBehaviour.self)

		let current = Settings(completionBehaviour: completionBehaviour ?? .regular)

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
