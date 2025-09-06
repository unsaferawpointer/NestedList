//
//  ColumnHeaderView.swift
//  Nested List
//
//  Created by Anton Cherkasov on 16.08.2025.
//

import AppKit

class ColumnHeaderView: NSView {

	// MARK: - UI

	var buttonMenu: NSMenu?

	// MARK: - UI-Properties

	lazy var titleTextfield: NSTextField = {
		let view = NSTextField()
		view.focusRingType = .default
		view.cell?.sendsActionOnEndEditing = true
		view.isBordered = false
		view.isEditable = false
		view.drawsBackground = false
		view.usesSingleLineMode = true
		view.lineBreakMode = .byTruncatingMiddle
		view.font = NSFont.preferredFont(forTextStyle: .headline)
		view.allowsEditingTextAttributes = false
		return view
	}()

	lazy var buttons: NSStackView = {
		let view = NSStackView(views: [plusButton, actionButton])
		view.orientation = .horizontal
		view.spacing = 4
		return view
	}()

	lazy var actionButton: NSButton = {
		let image = NSImage.init(systemSymbolName: "ellipsis", accessibilityDescription: nil)!
		let action = #selector(buttonDidClick(_:))
		let button = NSButton(image: image, target: self, action: action)
		button.bezelStyle = .toolbar
		button.showsBorderOnlyWhileMouseInside = true
		return button
	}()

	lazy var plusButton: NSButton = {
		let image = NSImage.init(systemSymbolName: "plus", accessibilityDescription: nil)!
		let action = #selector(buttonDidClick(_:))
		let button = NSButton(image: image, target: self, action: action)
		button.bezelStyle = .toolbar
		button.showsBorderOnlyWhileMouseInside = true
		return button
	}()

	var leadingAction: (() -> Void)?

	// MARK: - Initialization

	init(menu: NSMenu?) {
		self.buttonMenu = menu
		super.init(frame: .zero)
		configureConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Actions
extension ColumnHeaderView {

	@objc
	func buttonDidClick(_ sender: NSButton) {
		if actionButton === sender {
			buttonMenu?.popUp(
				positioning: nil,
				at: .init(x: actionButton.bounds.midX, y: actionButton.bounds.maxY),
				in: sender
			)
		} else if plusButton === sender {
			leadingAction?()
		}
	}
}

// MARK: - Helpers
private extension ColumnHeaderView {

	func configureConstraints() {

		[titleTextfield, buttons].map { $0 }.forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}

		titleTextfield.setContentHuggingPriority(.defaultLow, for: .horizontal)
		titleTextfield.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

		buttons.setHuggingPriority(.defaultHigh, for: .horizontal)
		buttons.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

		[
			titleTextfield.topAnchor.constraint(equalTo: topAnchor, constant: 12),
			titleTextfield.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
			titleTextfield.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
			titleTextfield.trailingAnchor.constraint(equalTo: buttons.leadingAnchor, constant: -12),

			buttons.firstBaselineAnchor.constraint(equalTo: titleTextfield.firstBaselineAnchor),
			buttons.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
		]
			.forEach { $0.isActive = true }
	}

}
