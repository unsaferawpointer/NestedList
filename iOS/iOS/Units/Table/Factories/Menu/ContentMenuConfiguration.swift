//
//  ContentMenuConfiguration.swift
//  iOS
//
//  Created by Anton Cherkasov on 08.07.2026.
//

import Foundation

struct ContentMenuConfiguration {
	var state: [String: Bool] = [:]
	var canFocus = false
}

extension ContentMenuConfiguration {

	subscript(id: String) -> Bool? {
		return state[id]
	}
}
