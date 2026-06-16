//
//  DetailsLocalization.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.04.2025.
//

import Foundation

struct DetailsLocalization {
	let saveButtonTitle = String(
		localized: "save-item-title",
		table: "DetailsLocalizable",
		bundle: .module
	)
	let cancelButtonTitle = String(
		localized: "cancel-item-title",
		table: "DetailsLocalizable",
		bundle: .module
	)
	let propertiesSectionTitle = String(
		localized: "properties-section-title",
		table: "DetailsLocalizable",
		bundle: .module
	)
	let textfieldPlaceholder = String(
		localized: "textfield-placeholder",
		table: "DetailsLocalizable",
		bundle: .module
	)
	let notePlaceholder = String(
		localized: "note-placeholder",
		table: "DetailsLocalizable",
		bundle: .module
	)
	let warningText = String(
		localized: "warning-text",
		table: "DetailsLocalizable",
		bundle: .module
	)
}
