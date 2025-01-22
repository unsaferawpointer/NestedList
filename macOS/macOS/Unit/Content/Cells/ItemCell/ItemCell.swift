//
//  ItemCell.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import DesignSystem
import CoreModule
import SwiftUI

final class ItemCell: NSView, ListCell {

	typealias Model = ItemModel

	static var reuseIdentifier: String = "item_cell"

	var model: Model {
		didSet {
			updateUserInterface()
		}
	}

	var delegate: (any CellDelegate<ItemModel>)?

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
		let view = NSView()
		view.wantsLayer = true
		view.layer?.cornerRadius = 3
		view.layer?.borderWidth = 1
		NSLayoutConstraint.activate(
			[
				view.widthAnchor.constraint(equalToConstant: 6),
				view.heightAnchor.constraint(equalToConstant: 6),
			]
		)
		return view
	}()

	lazy var iconView: NSImageView = {
		let view = NSImageView()
		view.image?.isTemplate = true
		return view
	}()

	lazy var container: NSStackView = {
		let view = NSStackView(views: [prefixView, iconView, textfield])
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

	override func layout() {
		super.layout()
		prefixView.layer?.backgroundColor = model.configuration.point?.color.value.cgColor
		prefixView.layer?.borderColor = NSColor.separatorColor.cgColor
	}

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
			textColor: configuration.text.colorToken.value,
			strikethrough: configuration.text.strikethrough
		)
		textfield.font = NSFont.preferredFont(forTextStyle: configuration.text.style)

		if let pointConfiguration = configuration.point {
			prefixView.isHidden = false
			prefixView.layer?.backgroundColor = pointConfiguration.color.value.cgColor
		} else {
			prefixView.isHidden = true
			prefixView.layer?.backgroundColor = nil
		}

		if let iconConfiguration = configuration.icon {
			iconView.isHidden = false
			iconView.image = NSImage(systemSymbolName: iconConfiguration.iconName, accessibilityDescription: nil)
			iconView.contentTintColor = iconConfiguration.color.value
		} else {
			iconView.isHidden = true
		}

		// Value
		textfield.attributedStringValue = attrString

		textfield.allowsEditingTextAttributes = false
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

		delegate?.cellDidChange(newValue: .init(text: text), id: model.id)
	}

}
