//
//  ColorPickerScreen.swift
//  iOS
//
//  Created by Anton Cherkasov on 29.03.2026.
//

import SwiftUI
import DesignSystem
import CoreModule
import CorePresentation

struct ColorPickerScreen {

	let action: @MainActor (ItemColor?) -> Void
}

extension ColorPickerScreen {

	var colors: [ColorToken] {
		ItemColor.allCases.map {
			ColorMapper.map(color: $0)
		}
	}

	var title: String {
		String(
			localized: "color-picker-title",
			table: "PickerLocalizable"
		)
	}
}

// MARK: - View
extension ColorPickerScreen: View {

	var body: some View {
		NavigationStack {
			ScrollView {
				CommonPicker(values: colors) {
					PickerButton(
						icon: .circleSlash,
						foregroundColor: .primary,
						backgroundColor: .gray.opacity(0.1)
					) {
						action(nil)
					}
				} content: { token in
					PickerButton(
						icon: .filledCircle,
						showsThemeVariants: true,
						foregroundColor: token.color,
						backgroundColor: .gray.opacity(0.1)
					) {
						action(ColorMapper.map(token: token))
					}
				}
			}
			.navigationTitle(title)
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

#Preview {
	ColorPickerScreen { _ in }
}
