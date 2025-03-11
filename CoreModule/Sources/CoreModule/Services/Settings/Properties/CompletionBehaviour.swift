//
//  CompletionBehaviour.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 11.03.2025.
//

import Foundation

public enum CompletionBehaviour: Int {
	case regular = 0
	case moveToEnd
}

// MARK: - Hashable
extension CompletionBehaviour: Hashable { }

// MARK: - SettingsProperty
extension CompletionBehaviour: SettingsProperty {

	static var key: String {
		"completion_behaviour"
	}
}
