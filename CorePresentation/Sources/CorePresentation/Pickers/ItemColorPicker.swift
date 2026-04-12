//
//  ItemColorPicker.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 12.04.2026.
//

import SwiftUI
import DesignSystem
import CoreModule

public struct ItemColorPicker {

	let title: String

	let action: @MainActor (ItemColor?, Bool) -> Void

	// MARK: - Initialization

	public init(
		title: String,
		action: @escaping @MainActor (ItemColor?, Bool) -> Void
	) {
		self.title = title
		self.action = action
	}
}

// MARK: - View
extension ItemColorPicker: View {

	public var body: some View {
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
						showsThemeVariants: true,
						foregroundColor: token.color,
						backgroundColor: .gray.opacity(0.1)
					) {
						action(ColorMapper.map(token: token), true)
					}
				}
			}
			.scrollIndicators(.hidden)
			.toolbar {
				buildToolbar(action: action)
			}
			.navigationTitle(title)
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
		}
		.frame(minWidth: 320, minHeight: 320, maxHeight: 640)
	}
}

// MARK: - Helpers
private extension ItemColorPicker {

	var colors: [ColorToken] {
		ItemColor.allCases.map {
			ColorMapper.map(color: $0)
		}
	}
}

#if os(iOS)
private extension ItemColorPicker {

	@ToolbarContentBuilder
	func buildToolbar(action: @escaping @MainActor (ItemColor?, Bool) -> Void) -> some ToolbarContent {
		if #available(iOS 26.0, *) {
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
#endif

#if os(macOS)
private extension ItemColorPicker {

	@ToolbarContentBuilder
	func buildToolbar(action: @escaping @MainActor (ItemColor?, Bool) -> Void) -> some ToolbarContent {
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
#endif

#Preview {
	ItemColorPicker(title: "Choose Color") { _, _ in }
}
