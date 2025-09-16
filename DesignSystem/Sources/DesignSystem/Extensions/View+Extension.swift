//
//  NSView+Extension.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 12.01.2025.
//

#if canImport(AppKit)
import AppKit

public extension NSView {

	func pin(edges: ViewAnchor, to view: NSView, with inset: CGFloat = 0) {
		translatesAutoresizingMaskIntoConstraints = false
		if !view.subviews.contains(where: { $0 == self}) {
			view.addSubview(self)
		}

		if edges.contains(.top) {
			topAnchor.constraint(equalTo: view.topAnchor, constant: inset).isActive = true
		}

		if edges.contains(.leading) {
			leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset).isActive = true
		}

		if edges.contains(.trailing) {
			trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset).isActive = true
		}

		if edges.contains(.bottom) {
			bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset).isActive = true
		}
	}
}
#elseif canImport(UIKit)
import UIKit

public extension UIView {

	func pin(edges: ViewAnchor, to view: UIView, with inset: CGFloat = 0) {
		translatesAutoresizingMaskIntoConstraints = false
		if !view.subviews.contains(where: { $0 == self}) {
			view.addSubview(self)
		}

		if edges.contains(.top) {
			topAnchor.constraint(equalTo: view.topAnchor, constant: inset).isActive = true
		}

		if edges.contains(.leading) {
			leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset).isActive = true
		}

		if edges.contains(.trailing) {
			trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset).isActive = true
		}

		if edges.contains(.bottom) {
			bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset).isActive = true
		}
	}
}
#endif

public struct ViewAnchor: OptionSet {

	public static let top = ViewAnchor(rawValue: 1 << 0)
	public static let leading = ViewAnchor(rawValue: 1 << 1)
	public static let trailing = ViewAnchor(rawValue: 1 << 2)
	public static let bottom = ViewAnchor(rawValue: 1 << 3)

	public static let all: ViewAnchor = [top, leading, trailing, bottom]

	public var rawValue: Int

	public init(rawValue: Int) {
		self.rawValue = rawValue
	}
}
