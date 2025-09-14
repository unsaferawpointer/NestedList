//
//  ItemView.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 14.09.2025.
//

import SwiftUI

struct ItemView: View {

	let item: Item

	var body: some View {
		HStack(alignment: .firstTextBaseline) {
			if let iconName = item.iconName {
				Image(systemName: iconName)
					.foregroundStyle(item.iconColor ?? .primary)
					.symbolColorRenderingMode(.gradient)
			}
			VStack(alignment: .leading) {
				Text(item.title)
					.font(item.titleIsBold ? .headline : .body)
					.foregroundStyle(.primary)
				if let subtitle = item.subtitle {
					Text(subtitle)
						.font(.footnote)
						.foregroundStyle(.secondary)
				}
			}
			Spacer()
		}
	}
}

// MARK: - Nested data structs
extension ItemView {

	struct Item: Identifiable {

		var id: UUID = .init()

		var iconName: String?

		var iconColor: Color?

		var title: String

		var titleIsBold: Bool = false

		var subtitle: String?

		var children: [Item]?
	}
}

#Preview {
	VStack(alignment: .center) {
		ItemView(item: .init(title: "Title", subtitle: "Subtitle"))
		Divider()
		ItemView(item: .init(title: "Title", subtitle: nil))
		Divider()
		ItemView(
			item: .init(
				iconName: "folder",
				iconColor: .indigo,
				title: "Title",
				titleIsBold: true,
				subtitle: "Note",
				children: []
			)
		)
		Divider()
		ItemView(item: .init(iconName: "star", iconColor: .yellow, title: "Title"))
	}
}
