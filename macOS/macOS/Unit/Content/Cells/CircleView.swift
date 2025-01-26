//
//  CircleView.swift
//  Nested List
//
//  Created by Anton Cherkasov on 26.01.2025.
//

import Cocoa
import DesignSystem

class CircleView: NSView {

	var color: ColorToken = .accent {
		didSet {
			needsDisplay = true
		}
	}

	let borderWidth: CGFloat = 1

	override func draw(_ dirtyRect: NSRect) {
		color.value.setFill()
		NSColor.tertiaryLabelColor.withAlphaComponent(0.15).setStroke()

		let path = NSBezierPath(ovalIn: bounds)
		path.lineWidth = borderWidth
		path.fill()
		path.stroke()
	}

	override var intrinsicContentSize: NSSize {
		.init(width: 6, height: 6)
	}

}
