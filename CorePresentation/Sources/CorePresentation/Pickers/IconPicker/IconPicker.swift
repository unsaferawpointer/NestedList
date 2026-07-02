//
//  IconPicker.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 12.04.2026.
//

import SwiftUI
import CoreModule
import DesignSystem

@MainActor public struct IconPicker {

	private let model: IconPickerViewModel

	// MARK: - Initialization

	public init(
		title: String,
		action: @escaping @MainActor (IconName?, Bool) -> Void
	) {
		self.model = IconPickerViewModel(title: title, action: action)
	}
}

// MARK: - View
extension IconPicker: View {

	public var body: some View {
		NavigationStack {
			ScrollView {
				CommonPicker(values: model.icons) {
					PickerButton(
						icon: .circleSlash,
						foregroundColor: .red,
						backgroundColor: .gray.opacity(0.1)
					) {
						model.selectNone()
					}
				} content: { icon in
					PickerButton(
						icon: icon,
						foregroundColor: .primary,
						backgroundColor: .gray.opacity(0.1)
					) {
						model.select(icon)
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
		#if os(macOS)
		.frame(minWidth: 320, minHeight: 320, maxHeight: 640)
		#endif
	}
}

// MARK: - Helpers
#if os(iOS)
private extension IconPicker {

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
private extension IconPicker {

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
	IconPicker(title: "Choose Icon") { _, _ in }
}
