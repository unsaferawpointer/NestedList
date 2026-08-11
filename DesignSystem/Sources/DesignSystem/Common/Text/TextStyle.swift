//
//  TextStyle.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 28.06.2026.
//

import Foundation

public enum TextStyle {
	case body
	case callout
	case headline
}

// MARK: - Hashable
extension TextStyle: Hashable { }

#if canImport(UIKit)
import UIKit

public extension TextStyle {

	var value: UIFont.TextStyle {
		switch self {
		case .body:
			return .body
		case .callout:
			return .callout
		case .headline:
			return .headline
		}
	}
}
#elseif canImport(AppKit)
import AppKit

public extension TextStyle {

	var value: NSFont.TextStyle {
		switch self {
		case .body:
			return .body
		case .callout:
			return .callout
		case .headline:
			return .headline
		}
	}
}
#endif
