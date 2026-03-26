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

	private let iconSlotWidth: CGFloat = 20

	// MARK: - ListCell

	typealias Model = ItemModel

	static var reuseIdentifier: String = "item_cell"

	var model: Model {
		didSet {
			let oldIconValue = oldValue.configuration.icon?.name
			let newIconValue = model.configuration.icon?.name
			let shouldAnimateIcon = oldValue.id == model.id && oldIconValue != newIconValue
			updateUserInterface(
				animateIcon: shouldAnimateIcon
			)
		}
	}

	weak var delegate: (any CellDelegate<ItemModel>)?

	func focus(on field: String) {
		switch field {
		case "title":
			titleTextfield.becomeFirstResponder()
		case "subtitle":
			subtitleTextfield.becomeFirstResponder()
		default:
			_ = becomeFirstResponder()
		}
	}

	// MARK: - UI-Properties

	lazy var titleTextfield: NSTextField = {
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
		view.allowsEditingTextAttributes = false
		return view
	}()

	lazy var subtitleTextfield: NSTextField = {
		let view = NSTextField()
		view.focusRingType = .default
		view.cell?.sendsActionOnEndEditing = true
		view.isBordered = false
		view.drawsBackground = false
		view.usesSingleLineMode = true
		view.lineBreakMode = .byTruncatingMiddle
		view.font = NSFont.preferredFont(forTextStyle: .callout)
		view.textColor = .secondaryLabelColor
		view.target = self
		view.action = #selector(textfieldDidChange(_:))
		view.allowsEditingTextAttributes = false
		view.placeholderString = "Item Description"
		return view
	}()

	lazy var textfieldsContainer: NSStackView = {
		let view = NSStackView(views: [titleTextfield, subtitleTextfield])
		view.orientation = .vertical
		view.distribution = .fill
		view.alignment = .leading
		view.spacing = 2
		return view
	}()

	lazy var iconView: NSImageView = {
		let view = NSImageView()
		view.image?.isTemplate = true
		view.imageAlignment = .alignCenter
		return view
	}()

	lazy var container: NSStackView = {
		let view = NSStackView(views: [iconView, textfieldsContainer])
		view.orientation = .horizontal
		view.distribution = .fill
		view.spacing = 6
		view.alignment = .centerY
		return view
	}()

	// MARK: - Initialization

	init(_ model: Model) {
		self.model = model
		super.init(frame: .zero)
		configureConstraints()
		updateUserInterface(animateIcon: false)
	}

	@available(*, unavailable, message: "Use init(textDidChange: checkboxDidChange:)")
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - NSView life-cycle

	override func becomeFirstResponder() -> Bool {
		super.becomeFirstResponder()
		return titleTextfield.becomeFirstResponder()
	}
}

// MARK: - Helpers
private extension ItemCell {

	func updateUserInterface(animateIcon: Bool) {

		let value = model.value
		let configuration = model.configuration

		let attrString = NSAttributedString(
			string: value.title,
			textColor: configuration.text.colorToken.value,
			strikethrough: configuration.text.strikethrough
		)
		titleTextfield.font = NSFont.preferredFont(forTextStyle: configuration.text.style)

		setIcon(configuration: model.configuration.icon, animateIcon: animateIcon)

		// Value
		titleTextfield.attributedStringValue = attrString

		subtitleTextfield.isHidden = value.subtitle == nil
		subtitleTextfield.stringValue = value.subtitle ?? ""
	}

	func configureConstraints() {

		[container].map { $0 }.forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}

		[
			iconView.widthAnchor.constraint(equalToConstant: iconSlotWidth),
			container.centerYAnchor.constraint(equalTo: centerYAnchor),
			container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
			container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
		]
			.forEach { $0.isActive = true }

	}

	func setIcon(configuration: IconConfiguration?, animateIcon: Bool) {

		iconView.isHidden = configuration == nil

		guard let configuration else {
			iconView.image = nil
			return
		}

		let image = configuration.name?.nsImage?
			.withSymbolConfiguration(
				configuration.appearence.configuration
					.applying(
						.init(textStyle: model.configuration.text.style)
					)
			)

		iconView.contentTintColor = configuration.appearence.tint
		guard let image else {
			iconView.image = nil
			return
		}

		if #available(macOS 14.0, *), animateIcon {
			iconView.setSymbolImage(image, contentTransition: .replace)
		} else {
			iconView.image = image
		}
	}
}

// MARK: - Actions
extension ItemCell {

	@objc
	func textfieldDidChange(_ sender: NSTextField) {

		guard sender === titleTextfield || sender === subtitleTextfield else {
			return
		}

		let title = titleTextfield.stringValue
		let subtitle = subtitleTextfield.stringValue

		delegate?.cellDidChange(newValue: .init(title: title, subtitle: subtitle), id: model.id)
	}

}
