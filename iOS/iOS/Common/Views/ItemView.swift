//
//  ItemView.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.09.2025.
//

import SwiftUI

struct ItemView: View {

	@State var model: ItemViewModel

	var body: some View {
		HStack(alignment: .firstTextBaseline) {
			if let image = model.icon?.image {
				image
					.foregroundStyle(model.isDisabled ? .secondary : .primary)
			}
			Text(model.title)
				.foregroundStyle(model.isDisabled ? .secondary : .primary)
				.font(Font.system(model.textStyle))
		}
	}
}

#Preview {
	VStack(alignment: .leading, spacing: 4) {
		ItemView(
			model: .init(
				id: UUID(),
				title: "Section Item",
				textStyle: .headline,
				icon: .folder(filled: false)
			)
		)
		ItemView(
			model: .init(
				id: UUID(),
				title: "Default Item",
				textStyle: .body,
				icon: .point
			)
		)
		ItemView(
			model: .init(
				id: UUID(),
				title: "Section Item",
				textStyle: .headline,
				icon: nil
			)
		)
		ItemView(
			model: .init(
				id: UUID(),
				title: "Default Item",
				textStyle: .body,
				icon: .point,
				isDisabled: true
			)
		)
	}
	.frame(maxWidth: .infinity, alignment: .leading)
}
