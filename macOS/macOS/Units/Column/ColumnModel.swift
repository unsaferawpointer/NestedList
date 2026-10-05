//
//  ColumnModel.swift
//  Nested List
//
//  Created by Anton Cherkasov on 13.08.2026.
//

import CorePresentation

struct ColumnModel {

	let title: String

	let configuration: ItemModel.Configuration
}

// MARK: - Initialization
extension ColumnModel {

	init(presentation: ItemPresentation) {
		self.init(
			title: presentation.title.value,
			configuration: .init(presentation: presentation)
		)
	}
}
