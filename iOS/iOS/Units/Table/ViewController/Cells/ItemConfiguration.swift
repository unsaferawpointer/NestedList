//
//  ItemConfiguration.swift
//  iOS
//
//  Created by Anton Cherkasov on 30.07.2026.
//

import UIKit
import DesignSystem

/// Custom content configuration for an item cell.
///
/// Carries the semantic data needed to render an item (icon, title, subtitle)
/// and produces a hand-built ``ItemView`` instead of relying on `UIListContentConfiguration`.
struct ItemConfiguration {

	var icon: IconConfiguration?

	var title: TextConfiguration

	var subtitle: TextConfiguration?

	var showsTrailingDisclosure: Bool
}

// MARK: - UIContentConfiguration
extension ItemConfiguration: UIContentConfiguration {

	func makeContentView() -> any UIView & UIContentView {
		return ItemConfigurationView(configuration: self)
	}

	func updated(for state: any UIConfigurationState) -> ItemConfiguration {
		return self
	}
}

// MARK: - Equatable
extension ItemConfiguration: Equatable { }
