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

	// MARK: - Internal State

	private let columns: [GridItem] =
	[
		GridItem(.adaptive(minimum: 48), spacing: 8)
	]
}

extension IconPickerScreen {

	var icons: [SemanticImage] {
		IconName.allCases.map {
			IconMapper.map(icon: $0)
		}
	}
}

// MARK: - View
extension IconPickerScreen: View {

	public var body: some View {
		NavigationStack {
			ScrollView {
				LazyVGrid(columns: columns, spacing: 15) {
					PickerButton(icon: .circleSlash, foregroundColor: .primary) {
						action(nil)
					}
					ForEach(icons, id: \.self) { icon in
						PickerButton(icon: icon, foregroundColor: .primary) {
							action(IconMapper.map(icon: icon))
						}
					}
				}
				.padding()
				.frame(minWidth: 240)
			}
			.listStyle(.plain)
			.navigationTitle(
				String(
					localized: "icons-picker-title",
					table: "PickerLocalizable"
				)
			)
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

#Preview {
	IconPickerScreen { _ in }
}
