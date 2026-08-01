//
//  ContainerConfiguration.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 30.07.2026.
//

#if canImport(UIKit)
import UIKit

struct ContainerConfiguration<C: CellContent> {
	var id: C.ID
	var row: RowConfiguration
	var content: C
}

// MARK: - UIContentConfiguration
extension ContainerConfiguration: UIContentConfiguration {

	func makeContentView() -> any UIView & UIContentView {
		return ContainerView(configuration: self)
	}

	func updated(for state: any UIConfigurationState) -> ContainerConfiguration<C> {
		var result = self
		result.content = content.updated(for: state)
		return result
	}
}
#endif
