//
//  ItemCell.swift
//  iOS
//
//  Created by Anton Cherkasov on 08.03.2025.
//

import UIKit

class ItemCell: UITableViewCell {

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		validateIndent()
	}
}

// MARK: - Public interface
extension ItemCell {

	func validateIndent() {

		let isPad = UIDevice.current.userInterfaceIdiom == .pad
		let attenuation = isPad ? 0.1 : 0.4

		let interval = frame.width - 240.0
		let level = Double(indentationLevel)
		let offset = interval - exp(-attenuation * level) * interval

		if indentationLevel != 0 {
			indentationWidth = offset / CGFloat(indentationLevel)
		} else {
			indentationWidth = 0
		}
	}
}
