//
//  ItemCell.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import DesignSystem
import SwiftUI

final class ItemCell: NSView, ListCell {

	typealias Model = ItemModel

	static var reuseIdentifier: String = "item_cell"

	var model: Model {
		didSet {
			updateUserInterface()
		}
	}

	var action: ((Model.Value) -> Void)?

	// MARK: - UI-Properties

	lazy var textfield: NSTextField = {
		let view = NSTextField()
		view.focusRingType = .default
		view.cell?.sendsActionOnEndEditing = true
		view.isBordered = false
		view.drawsBackground = false
		view.usesSingleLineMode = true
		view.lineBreakMode = .byTruncatingMiddle
		view.font = NSFont.preferredFont(forTextStyle: .body)
		view.target = self
		view.action = #selector(textfieldDidChange(_:))
		return view
	}()

	lazy var prefixView: NSView = {
		let view = NSHostingView(rootView: ItemSignView())
		return view
	}()

	lazy var container: NSStackView = {
		let view = NSStackView(views: [prefixView, textfield])
		view.orientation = .horizontal
		view.distribution = .fillProportionally
		view.alignment = .centerY
		return view
	}()

	// MARK: - Initialization

	init(_ model: Model) {
		self.model = model
		super.init(frame: .zero)
		configureConstraints()
		updateUserInterface()
	}

	@available(*, unavailable, message: "Use init(textDidChange: checkboxDidChange:)")
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - NSView life-cycle

	override func becomeFirstResponder() -> Bool {
		super.becomeFirstResponder()
		return textfield.becomeFirstResponder()
	}
}

// MARK: - Helpers
private extension ItemCell {

	func updateUserInterface() {

		let value = model.value
		let configuration = model.configuration

		let attrString = NSAttributedString(
			string: value.text,
			textColor: configuration.textColor,
			strikethrough: configuration.strikethrough
		)

		// Value
		textfield.attributedStringValue = attrString

		textfield.allowsEditingTextAttributes = true
	}

	func configureConstraints() {

		[container].map { $0 }.forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}

		[
			container.centerYAnchor.constraint(equalTo: centerYAnchor),
			container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
			container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
		]
			.forEach { $0.isActive = true }

	}
}

// MARK: - Actions
extension ItemCell {

	@objc
	func textfieldDidChange(_ sender: NSTextField) {
		guard sender === textfield else {
			return
		}

		let text = sender.stringValue

		action?(.init(text: text))
	}

}

extension NSAttributedString {

	convenience init(string: String, textColor: NSColor, strikethrough: Bool = false) {
		let strikethroughStyle: NSUnderlineStyle = strikethrough ? .thick : []
		let strikethroughColor: NSColor = .secondaryLabelColor

		let attributes: [NSAttributedString.Key: Any] = [
			.strikethroughStyle: strikethroughStyle.rawValue,
			.foregroundColor: textColor,
			.strikethroughColor: strikethroughColor
		]
		self.init(string: string, attributes: attributes)
	}
}
