//
//  ItemContentConfiguration.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.06.2026.
//

import UIKit
import DesignSystem

struct ItemContentConfiguration<ID: Hashable> {
	var id: ID
	var row: RowConfiguration
	var content: UIListContentConfiguration
	var showsTrailingDisclosure: Bool
}

// MARK: - UIContentConfiguration
extension ItemContentConfiguration: UIContentConfiguration {

	func makeContentView() -> any UIView & UIContentView {
		return ItemContentView(configuration: self)
	}

	func updated(for state: any UIConfigurationState) -> ItemContentConfiguration<ID> {
		var result = self
		result.content = content.updated(for: state)
		return result
	}

}
