//
//  SectionStyle.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 13.03.2025.
//

import Foundation

public enum SectionStyle: Int {
	case noIcon = 0
	case icon
	case point
}

// MARK: - Hashable
extension SectionStyle: Hashable { }

// MARK: - SettingsProperty
extension SectionStyle: SettingsProperty {

	static var key: String {
		"section_style"
	}
}
