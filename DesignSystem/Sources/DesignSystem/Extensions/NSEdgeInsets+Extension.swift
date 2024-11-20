//
//  NSEdgeInsets+Extension.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Foundation

#if os(macOS)
public extension NSEdgeInsets {

	static func horizontal(_ inset: CGFloat) -> NSEdgeInsets {
		return .init(top: 0, left: inset, bottom: 0, right: inset)
	}
}
#endif
