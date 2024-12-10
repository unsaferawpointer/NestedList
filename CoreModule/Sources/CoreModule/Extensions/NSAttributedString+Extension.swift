//
//  NSAttributedString+Extension.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 09.12.2024.
//

import Foundation

#if canImport(AppKit)

import AppKit

public typealias Color = NSColor

fileprivate var strikethroughColor: Color = .secondaryLabelColor

#endif

#if canImport(UIKit)

import UIKit

public typealias Color = UIColor

fileprivate var strikethroughColor: Color = .secondaryLabel
#endif

public extension NSAttributedString {

	convenience init(string: String, textColor: Color, strikethrough: Bool = false) {
		let strikethroughStyle: NSUnderlineStyle = strikethrough ? .thick : []

		let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		paragraphStyle.lineBreakMode = .byTruncatingTail

		let attributes: [NSAttributedString.Key: Any] = [
			.paragraphStyle: paragraphStyle,
			.strikethroughStyle: strikethroughStyle.rawValue,
			.foregroundColor: textColor,
			.strikethroughColor: strikethroughColor
		]
		self.init(string: string, attributes: attributes)
	}
}
