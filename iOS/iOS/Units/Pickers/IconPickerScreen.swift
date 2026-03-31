//
//  IconPickerScreen.swift
//  iOS
//
//  Created by Anton Cherkasov on 29.03.2026.
//

import SwiftUI
import CoreModule
import DesignSystem
import CorePresentation

public struct IconPickerScreen {

	let action: @MainActor (IconName?) -> Void
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
						action(nil)
					}
				} content: { icon in
					PickerButton(
						icon: icon,
						foregroundColor: .primary,
						backgroundColor: .gray.opacity(0.1)
					) {
						action(IconMapper.map(icon: icon))
					}
				}
			}
			.navigationTitle(title)
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

#Preview {
	IconPickerScreen { _ in }
}
