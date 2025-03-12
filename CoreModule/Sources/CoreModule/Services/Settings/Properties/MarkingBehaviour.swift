//
//  MarkingBehaviour.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 12.03.2025.
//

import Foundation

public enum MarkingBehaviour: Int {
	case regular = 0
	case moveToTop
}

// MARK: - Hashable
extension MarkingBehaviour: Hashable { }

// MARK: - SettingsProperty
extension MarkingBehaviour: SettingsProperty {

	static var key: String {
		"marking_behaviour"
	}
}
