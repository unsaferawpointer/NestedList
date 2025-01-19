//
//  NSView+Extension.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 12.01.2025.
//

#if canImport(AppKit)
import AppKit

public extension NSView {

	func pin(edges: Edges, to view: NSView, with inset: CGFloat = 0) {
		translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(self)

		if edges.contains(.top) {
			topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		}

		if edges.contains(.leading) {
			leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		}

		if edges.contains(.trailing) {
			trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		}

		if edges.contains(.bottom) {
			bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		}
	}
}

// MARK: - Nested data structs
public extension NSView {

	struct Edges: OptionSet {

		public static let top = Edges(rawValue: 1 << 0)
		public static let leading = Edges(rawValue: 1 << 1)
		public static let trailing = Edges(rawValue: 1 << 2)
		public static let bottom = Edges(rawValue: 1 << 3)

		public static let all: Edges = [top, leading, trailing, bottom]

		public var rawValue: Int

		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}
}
#endif
