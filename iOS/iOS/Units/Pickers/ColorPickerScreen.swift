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

	// MARK: - Internal State

	private let columns: [GridItem] =
	[
		GridItem(.adaptive(minimum: 48), spacing: 8)
	]
}

extension ColorPickerScreen {

	var colors: [ColorToken] {
		ItemColor.allCases.map {
			ColorMapper.map(color: $0)
		}
	}
}

// MARK: - View
extension ColorPickerScreen: View {

	var body: some View {
		NavigationStack {
			ScrollView {
				LazyVGrid(columns: columns, spacing: 15) {
					PickerButton(icon: .circleSlash, foregroundColor: .primary) {
						action(nil)
					}
					ForEach(colors, id: \.self) { token in
						PickerButton(
							icon: .filledCircle,
							foregroundColor: token.color
						) {
							action(ColorMapper.map(token: token))
						}
					}
				}
				.padding()
				.frame(minWidth: 240)
			}
			.listStyle(.plain)
				.navigationTitle(
					String(
						localized: "color-picker-title",
						table: "PickerLocalizable"
					)
				)
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

#Preview {
	ColorPickerScreen { _ in }
}
