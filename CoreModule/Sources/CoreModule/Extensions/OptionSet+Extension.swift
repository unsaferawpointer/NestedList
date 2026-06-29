//
//  OptionSet+Extension.swift
//  CoreModule
//
//  Created by Codex on 29.06.2026.
//

import Foundation

public extension OptionSet where Element == Self {

	mutating func set(_ option: Self, enabled: Bool) {
		if enabled {
			insert(option)
		} else {
			remove(option)
		}
	}
}
