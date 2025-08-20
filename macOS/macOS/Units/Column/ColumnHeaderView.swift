//
//  ColumnHeaderView.swift
//  Nested List
//
//  Created by Anton Cherkasov on 16.08.2025.
//

import AppKit

class ColumnHeaderView: NSView {

	// MARK: - UI

	let buttonMenu: NSMenu

	// MARK: - UI-Properties

	lazy var titleTextfield: NSTextField = {
		let view = NSTextField()
		view.focusRingType = .default
		view.cell?.sendsActionOnEndEditing = true
		view.isBordered = false
		view.drawsBackground = false
		view.usesSingleLineMode = true
		view.lineBreakMode = .byTruncatingMiddle
		view.font = NSFont.preferredFont(forTextStyle: .headline)
		view.target = self
		view.action = #selector(textfieldDidChange(_:))
		view.allowsEditingTextAttributes = false
		return view
	}()

	lazy var actionButton: NSButton = {
		let image = NSImage.init(systemSymbolName: "ellipsis", accessibilityDescription: nil)!
		let action = #selector(buttonDidClick(_:))
		let button = NSButton(image: image, target: self, action: action)
		button.showsBorderOnlyWhileMouseInside = true
		return button
	}()

	// MARK: - Initialization

	init(menu: NSMenu) {
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
		buttonMenu.popUp(
			positioning: nil,
			at: .init(x: actionButton.bounds.midX, y: actionButton.bounds.maxY),
			in: sender
		)
	}
}

// MARK: - Helpers
private extension ColumnHeaderView {

	func configureConstraints() {

		[titleTextfield, actionButton].map { $0 }.forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}

		[
			titleTextfield.topAnchor.constraint(equalTo: topAnchor, constant: 12),
			titleTextfield.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
			titleTextfield.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
			titleTextfield.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -12),

			actionButton.firstBaselineAnchor.constraint(equalTo: titleTextfield.firstBaselineAnchor),
			actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
		]
			.forEach { $0.isActive = true }

	}

}

// MARK: - Actions
extension ColumnHeaderView {

	@objc
	func textfieldDidChange(_ sender: NSTextField) {

		guard sender === titleTextfield else {
			return
		}

		let title = titleTextfield.stringValue

//		fatalError()
	}

}
