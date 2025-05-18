//
//  MarkingBehavior.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 12.03.2025.
//

import Foundation

public enum MarkingBehavior: Int {
	case regular = 0
	case moveToTop
}

// MARK: - Hashable
extension MarkingBehavior: Hashable { }

// MARK: - SettingsProperty
extension MarkingBehavior: SettingsProperty {

	static var defaultValue: MarkingBehavior? {
		return .regular
	}

	static var key: String {
		"marking_behavior"
	}
}
