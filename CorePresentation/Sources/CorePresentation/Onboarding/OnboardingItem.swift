//
//  OnboardingItem.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 11.11.2026.
//

import DesignSystem
import Foundation

/// Mutable display data for a fake item in an onboarding scene.
struct OnboardingItem {

	// MARK: - Identity

	var id: UUID = UUID()

	// MARK: - Content

	var title: Text

	var subtitle: Text? = nil

	var icon: IconConfiguration = .init(name: .point, token: .primary)

	// MARK: - Hierarchy

	var state: HierarchyState = .leaf

	var level: Int = 0

	// MARK: - Presentation state

	var isSelected: Bool = false

	var showsTrailingDisclosure: Bool = false
}

// MARK: - Identifiable
extension OnboardingItem: Identifiable { }

// MARK: - Equatable
extension OnboardingItem: Equatable { }

// MARK: - Nested data structs
extension OnboardingItem {

	struct Text {

		var value: String

		var style: TextStyle = .body

		var colorToken: ColorToken = .primary

		var strikethrough: Bool = false

		var showsCaret: Bool = false
	}
}

// MARK: - Nested data structs
extension OnboardingItem {

	enum HierarchyState {
		case leaf
		case collapsed
		case expanded
	}
}

// MARK: - Equatable
extension OnboardingItem.HierarchyState: Equatable { }

// MARK: - Equatable
extension OnboardingItem.Text: Equatable { }
