//
//  Dictionary+Extension.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

public extension Dictionary {

	subscript(unsafe key: Key) -> Value {
		guard let value = self[key] else {
			fatalError("Value by key = \(key) not found")
		}
		return value
	}

	subscript(optional key: Key?) -> Value? {
		guard let key else {
			return nil
		}
		return self[key]
	}
}
