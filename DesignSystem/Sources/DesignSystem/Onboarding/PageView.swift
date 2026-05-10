//
//  PageView.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 10.05.2026.
//

import SwiftUI

struct PageView {
	let systemName: String
	let title: String
	let description: String
}

// MARK: - View
extension PageView: View {

	var body: some View {
		VStack(spacing: 8) {
			GeometryReader { proxy in
				VStack {
					Spacer()
					Image(systemName: systemName)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(height: proxy.size.height * 0.5)
					Spacer()
				}
				.frame(
					maxWidth: .infinity,
					maxHeight: .infinity,
					alignment: .center
				)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			Text(title)
				.font(titleFont)
				.fontWeight(.bold)
				.foregroundStyle(.primary)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 32)
			Text(description)
				.font(descriptionFont)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 36)
		}
	}
}

#if os(iOS)
private extension PageView {
	var titleFont: Font {
		.title
	}

	var descriptionFont: Font {
		.title2
	}
}
#elseif os(macOS)
private extension PageView {
	var titleFont: Font {
		.title
	}

	var descriptionFont: Font {
		.title3
	}
}
#endif

// MARK: - Builders
private extension PageView {

}

#Preview {
	PageView(
		systemName: "slider.horizontal.2.square.on.square",
		title: "Redesigned Icons",
		description: "Customize App Appearance"
	)
}
