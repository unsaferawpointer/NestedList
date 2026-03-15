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
			VStack {
				Image(systemName: model.icon)
					.resizable()
					.scaledToFit()
					.frame(width: 56, height: 56)
					.foregroundStyle(.quinary)
					.accessibilityHidden(true)
				Text(model.title)
					.font(.title)
					.fontWeight(.semibold)
					.foregroundStyle(.secondary)
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
			icon: "folder",
			title: "No items yet",
			subtitle: "To add a new item, click the «plus» button or use the keyboard shortcut cmd + t"
		)
	)
}
