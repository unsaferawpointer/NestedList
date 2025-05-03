//
//  NSUserInterfaceItemIdentifier+Extension.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 02.05.2025.
//

#if canImport(AppKit)

import AppKit

public extension NSUserInterfaceItemIdentifier {

	init(elementIdentifier: ElementIdentifier) {
		self.init(rawValue: elementIdentifier.rawValue)
	}
}

#endif
