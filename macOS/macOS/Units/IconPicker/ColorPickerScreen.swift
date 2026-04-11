//
//  ColorPickerScreen.swift
//  Nested List
//
//  Created by Anton Cherkasov on 11.04.2026.
//

import SwiftUI
import DesignSystem
import CoreModule
import CorePresentation

struct ColorPickerScreen {

	let action: @MainActor (ItemColor?, Bool) -> Void
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
						action(nil, true)
					}
				} content: { token in
					PickerButton(
						icon: .filledCircle,
						foregroundColor: token.color,
						backgroundColor: .gray.opacity(0.1)
					) {
						action(ColorMapper.map(token: token), true)
					}
				}
			}
			.scrollIndicators(.hidden)
			.toolbar {
				if #available(macOS 26.0, *) {
					ToolbarItem {
						Button {
							action(nil, false)
						} label: {
							Image(systemName: "xmark")
						}
					}
					.sharedBackgroundVisibility(.hidden)
				} else {
					ToolbarItem {
						Button {
							action(nil, false)
						} label: {
							Image(systemName: "xmark")
						}
					}
				}
			}
		}
		.frame(minWidth: 320, minHeight: 320, maxHeight: 640)
	}
}

#Preview {
	ColorPickerScreen { _, _ in }
}
