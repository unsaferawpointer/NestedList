//
//  OnboardingItemBuilder.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 11.11.2026.
//

import DesignSystem
import Foundation

/// A reusable template for creating independent items in onboarding scenes.
struct OnboardingItemBuilder {

	private var item: OnboardingItem

	// MARK: - Initialization

	init(title: String) {
		self.init(title: .init(value: title))
	}

	init(title: OnboardingItem.Text) {
		self.item = OnboardingItem(title: title)
	}
}

// MARK: - Configuration
extension OnboardingItemBuilder {

	func title(_ text: OnboardingItem.Text) -> Self {
		updating { $0.title = text }
	}

	func subtitle(_ text: OnboardingItem.Text?) -> Self {
		updating { $0.subtitle = text }
	}

	func icon(_ configuration: IconConfiguration) -> Self {
		updating { $0.icon = configuration }
	}

	func state(_ state: OnboardingItem.HierarchyState) -> Self {
		updating { $0.state = state }
	}

	func level(_ level: Int) -> Self {
		updating { $0.level = level }
	}

	func selected(_ value: Bool = true) -> Self {
		updating { $0.isSelected = value }
	}

	func trailingDisclosure(_ value: Bool = true) -> Self {
		updating { $0.showsTrailingDisclosure = value }
	}
}

// MARK: - Building
extension OnboardingItemBuilder {

	func build() -> OnboardingItem {
		var result = item
		result.id = UUID()
		return result
	}
}

// MARK: - Private methods
private extension OnboardingItemBuilder {

	func updating(_ update: (inout OnboardingItem) -> Void) -> Self {
		var result = self
		update(&result.item)
		return result
	}
}
