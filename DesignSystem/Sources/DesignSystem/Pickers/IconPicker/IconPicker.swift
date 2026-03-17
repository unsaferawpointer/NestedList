//
//  IconPicker.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.05.2025.
//

import SwiftUI

public struct IconPicker: View {

	@Binding var selection: IconModel

	// MARK: - Initialization

	public init(selection: Binding<IconModel>) {
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
			ForEach(SemanticImage.available, id: \.self) { icon in
				IconButton(icon: icon, isSelected: icon == selection.icon) {
					selection = .customIcon(icon)
				}
			}
		}
		.padding()
		.frame(minWidth: 240)
	}
}

extension SemanticImage {

	static var available: [SemanticImage] {
		return [
			.textDoc,
			.docOnDoc,
			.folder,
			.shippingbox,
			.archivebox,
			.squareStack,
			.book,
			.squareGrid2x2,
			.listStar,
			.star,
			.heart,
			.bolt
		]
	}
}

#Preview {
	IconPicker(selection: .constant(.customIcon(.docOnDoc)))
}
