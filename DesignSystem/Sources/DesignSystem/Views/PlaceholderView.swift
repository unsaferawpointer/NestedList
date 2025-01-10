//
//  PlaceholderView.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 10.01.2025.
//

import SwiftUI

public struct PlaceholderView: View {

	@State public var title: String

	@State public var subtitle: String

	public init(title: String, subtitle: String) {
		self.title = title
		self.subtitle = subtitle
	}

	public var body: some View {
		VStack {
			Image(systemName: "shippingbox")
				.resizable()
				.scaledToFit()
				.frame(width: 80, height: 80)
				.foregroundStyle(.quaternary)
			Text(title)
				.font(.title2)
				.foregroundStyle(.secondary)
				.lineLimit(1)
			Text(subtitle)
				.font(.body)
				.multilineTextAlignment(.center)
				.foregroundStyle(.tertiary)
				.lineLimit(nil)
		}
		.frame(width: 320)
		.padding()
	}
}

#Preview {
	PlaceholderView(
		title: "No items yet",
		subtitle: "To add a new item, click the «plus» button or use the keyboard shortcut cmd + t"
	)
	.frame(width: 240)
}
