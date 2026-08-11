//
//  SoundEffects.swift
//  CorePresentation
//
//  Created by Codex on 13.07.2026.
//

import Foundation

public enum SoundEffects: Int {
	case enabled = 0
	case disabled
}

// MARK: - Hashable
extension SoundEffects: Hashable { }

// MARK: - SettingsProperty
extension SoundEffects: SettingsProperty {

	static var defaultValue: SoundEffects? {
		return .enabled
	}

	static var key: String {
		"sound_effects"
	}
}
