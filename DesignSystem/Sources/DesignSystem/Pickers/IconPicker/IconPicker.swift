//
//  IconPicker.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.05.2025.
//

import SwiftUI

@MainActor
public struct IconPicker: View {

	@Binding var selection: IconModel

	let icons: [SemanticImage]

	// MARK: - Initialization

	@MainActor
	public init(icons: [SemanticImage], selection: Binding<IconModel>) {
		self.icons = icons
		self._selection = selection
	}

	#if os(iOS)
	let columns: [GridItem] = [GridItem(.adaptive(minimum: 64), spacing: 24)]
	#elseif os(macOS)
	let columns: [GridItem] = [GridItem(.adaptive(minimum: 32), spacing: 8)]
	#endif

	public var body: some View {
		LazyVGrid(columns: columns, spacing: 15) {
			IconButton(icon: .circleSlash, isSelected: selection == .noIcon) {
				selection = .noIcon
			}
			ForEach(icons, id: \.self) { icon in
				IconButton(icon: icon, isSelected: icon == selection.icon) {
					selection = .customIcon(icon)
				}
			}
		}
		.padding()
		.frame(minWidth: 240)
	}
}

#Preview {
	IconPicker(
		icons: [.airplane , .archivebox, .book],
		selection: .constant(.customIcon(.docOnDoc))
	)
}
