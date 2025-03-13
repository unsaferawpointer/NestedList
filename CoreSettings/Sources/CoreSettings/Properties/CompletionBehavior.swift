//
//  CompletionBehavior.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 11.03.2025.
//

import Foundation

public enum CompletionBehavior: Int {
	case regular = 0
	case moveToEnd
}

// MARK: - Hashable
extension CompletionBehavior: Hashable { }

// MARK: - SettingsProperty
extension CompletionBehavior: SettingsProperty {

	static var key: String {
		"completion_behavior"
	}
}
