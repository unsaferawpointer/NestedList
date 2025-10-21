//
//  ItemViewModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.09.2025.
//

import Foundation
import SwiftUI

import DesignSystem

struct ItemViewModel {

	let id: UUID

	let title: String

	let textStyle: Font.TextStyle

	let icon: SemanticImage?

	let isDisabled: Bool

	// MARK: - Initialization

	init(
		id: UUID,
		title: String,
		textStyle: Font.TextStyle,
		icon: SemanticImage?,
		isDisabled: Bool = false
	) {
		self.id = id
		self.title = title
		self.textStyle = textStyle
		self.icon = icon
		self.isDisabled = isDisabled
	}
}

// MARK: - Identifiable
extension ItemViewModel: Identifiable { }
