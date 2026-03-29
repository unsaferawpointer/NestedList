//
//  PlaceholderView.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 10.01.2025.
//

import SwiftUI

public struct PlaceholderModel {

	let icon: String

	let title: String

	let subtitle: String

	// MARK: - Initialization

	public init(icon: String, title: String, subtitle: String) {
		self.icon = icon
		self.title = title
		self.subtitle = subtitle
	}
}

public struct PlaceholderView: View {

	let model: PlaceholderModel

	public init(model: PlaceholderModel) {
		self.model = model
	}

	public var body: some View {
		ZStack(alignment: .center) {
			VStack(spacing: 8) {
				Image(systemName: model.icon)
					.resizable()
					.scaledToFit()
					.frame(width: 64, height: 64)
					.foregroundStyle(.quinary)
					.accessibilityHidden(true)
				Text(model.title)
					.font(.title)
					.fontWeight(.semibold)
					.foregroundStyle(.primary)
					.lineLimit(1)
				Text(model.subtitle)
					.font(.body)
					.multilineTextAlignment(.center)
					.foregroundStyle(.tertiary)
					.lineLimit(nil)
			}
			.frame(maxWidth: 280)
			.padding()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

#Preview {
	PlaceholderView(
		model: .init(
			icon: "plus.square.on.square",
			title: "No items yet",
			subtitle: "To add a new item, click the «plus» button or use the keyboard shortcut cmd + t"
		)
	)
}
