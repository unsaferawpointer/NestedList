//
//  File.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 12.04.2025.
//

#if canImport(AppKit)

import AppKit

public extension NSUserInterfaceItemIdentifier {

	init(elementIdentifier: ElementIdentifier) {
		self.init(rawValue: elementIdentifier.rawValue)
	}
}

#endif
