//
//  IconPicker.swift
//  Nested List
//
//  Created by Anton Cherkasov on 11.04.2026.
//

import SwiftUI
import CoreModule
import DesignSystem
import CorePresentation

public struct IconPickerScreen {

	let action: @MainActor (IconName?, Bool) -> Void
}

extension IconPickerScreen {

	var icons: [SemanticImage] {
		IconName.allCases.map {
			IconMapper.map(icon: $0)
		}
	}

	var title: String {
		String(
			localized: "icons-picker-title",
			table: "PickerLocalizable"
		)
	}
}

// MARK: - View
extension IconPickerScreen: View {

	public var body: some View {
		NavigationStack {
			ScrollView {
				CommonPicker(values: icons) {
					PickerButton(
						icon: .circleSlash,
						foregroundColor: .primary,
						backgroundColor: .gray.opacity(0.1)
					) {
						action(nil, true)
					}
				} content: { icon in
					PickerButton(
						icon: icon,
						foregroundColor: .primary,
						backgroundColor: .gray.opacity(0.1)
					) {
						action(IconMapper.map(icon: icon), true)
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
	IconPickerScreen { _, _ in }
}
