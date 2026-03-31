//
//  IconPicker.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.05.2025.
//

import SwiftUI

@MainActor
public struct IconPicker: View {

	@Binding var selection: SemanticImage?

	let icons: [SemanticImage]

	// MARK: - Initialization

	@MainActor
	public init(icons: [SemanticImage], selection: Binding<SemanticImage?>) {
		self.icons = icons
		self._selection = selection
	}

	public var body: some View {
		CommonPicker(values: icons) {
			PickerButton(
				icon: .circleSlash,
				foregroundColor: .primary,
				backgroundColor: selection == nil
					? .accentColor.opacity(0.2)
					: .gray.opacity(0.1)
			) {
				selection = nil
			}
		} content: { value in
			PickerButton(
				icon: value,
				foregroundColor: .primary,
				backgroundColor: selection == value
					? .accentColor.opacity(0.2)
					: .gray.opacity(0.1)
			) {
				selection = value
			}
		}
		.frame(minWidth: 240)
	}
}

#Preview {
	IconPicker(
		icons: [.airplane , .archivebox, .book],
		selection: .constant(.docOnDoc)
	)
}
