//
//  ItemCell.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import DesignSystem

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

	lazy var checkbox: NSButton = {
		let view = NSButton(
			checkboxWithTitle: "",
			target: self,
			action: #selector(checkboxDidChange(_:))
		)
		return view
	}()

	lazy var container: NSStackView = {
		let view = NSStackView(views: [checkbox, textfield])
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

		// Value
		textfield.stringValue = value.text
		checkbox.state = value.isOn ? .on : .off

		// Configuration
		textfield.textColor = configuration.textColor
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

		let isOn = checkbox.state == .on
		let text = sender.stringValue

		action?(.init(isOn: isOn, text: text))
	}

	@objc
	func checkboxDidChange(_ sender: NSButton) {
		guard sender === checkbox else {
			return
		}

		let isOn = sender.state == .on
		let text = textfield.stringValue

		action?(.init(isOn: isOn, text: text))
	}
}

