//
//  ItemColorPicker.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 12.04.2026.
//

import SwiftUI
import DesignSystem
import CoreModule

@MainActor public struct ItemColorPicker {

	private let model: ItemColorPickerViewModel

	// MARK: - Initialization

	public init(
		title: String,
		action: @escaping @MainActor (ItemColor?, Bool) -> Void
	) {
		self.model = ItemColorPickerViewModel(title: title, action: action)
	}
}

// MARK: - View
extension ItemColorPicker: View {

	public var body: some View {
		NavigationStack {
			ScrollView {
				CommonPicker(values: model.colors) {
					PickerButton(
						icon: .circleSlash,
						foregroundColor: .primary,
						backgroundColor: .gray.opacity(0.1)
					) {
						model.selectNone()
					}
				} content: { token in
					PickerButton(
						icon: .filledCircle,
						showsThemeVariants: true,
						foregroundColor: token.color,
						backgroundColor: .gray.opacity(0.1)
					) {
						model.select(token)
					}
				}
			}
			.scrollIndicators(.hidden)
			.toolbar {
				buildToolbar()
			}
			.navigationTitle(model.title)
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
		}
		.frame(minWidth: 320, minHeight: 320, maxHeight: 640)
	}
}

// MARK: - Helpers
#if os(iOS)
private extension ItemColorPicker {

	@MainActor
	@ToolbarContentBuilder
	func buildToolbar() -> some ToolbarContent {
		if #available(iOS 26.0, *) {
			ToolbarItem {
				Button {
					model.cancel()
				} label: {
					Image(systemName: "xmark")
				}
			}
			.sharedBackgroundVisibility(.hidden)
		} else {
			ToolbarItem {
				Button {
					model.cancel()
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

	@MainActor
	@ToolbarContentBuilder
	func buildToolbar() -> some ToolbarContent {
		if #available(macOS 26.0, *) {
			ToolbarItem {
				Button {
					model.cancel()
				} label: {
					Image(systemName: "xmark")
				}
			}
			.sharedBackgroundVisibility(.hidden)
		} else {
			ToolbarItem {
				Button {
					model.cancel()
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
