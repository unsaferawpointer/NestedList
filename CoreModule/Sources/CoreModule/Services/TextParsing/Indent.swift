//
//  Indent.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 26.01.2025.
//

import Foundation

public enum Indent {
	case space(value: Int)
	case tab

	var value: String {
		switch self {
		case .space(let value):
			return Array(repeating: " ", count: value).joined()
		case .tab:
			return "\t"
		}
	}
}
