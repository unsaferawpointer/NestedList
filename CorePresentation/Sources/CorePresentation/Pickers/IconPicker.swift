//
//  IconPicker.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 12.04.2026.
//

import SwiftUI
import CoreModule
import DesignSystem

public struct IconPicker {

	let title: String

	let action: @MainActor (IconName?, Bool) -> Void

	// MARK: - Initialization

	public init(
		title: String,
		action: @escaping @MainActor (IconName?, Bool) -> Void
	) {
		self.title = title
		self.action = action
	}
}

// MARK: - View
extension IconPicker: View {

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

// MARK: - Computed Properties
private extension IconPicker {

	var icons: [SemanticImage] {
		IconName.allCases.map {
			IconMapper.map(icon: $0)
		}
	}
}

// MARK: - Helpers
#if os(iOS)
private extension IconPicker {

	@ToolbarContentBuilder
	func buildToolbar(action: @escaping @MainActor (IconName?, Bool) -> Void) -> some ToolbarContent {
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
private extension IconPicker {

	@ToolbarContentBuilder
	func buildToolbar(action: @escaping @MainActor (IconName?, Bool) -> Void) -> some ToolbarContent {
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
	IconPicker(title: "Choose Icon") { _, _ in }
}
