//
//  OnboardingBody.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 30.04.2025.
//

import SwiftUI

struct OnboardingBody: View {

	let features: [Feature]

	var body: some View {
		VStack(alignment: .listRowSeparatorLeading, spacing: 24) {
			ForEach(features) { feature in
				HStack(alignment: .top, spacing: 12) {
					GeometryReader { geometry in
						let side = min(geometry.size.width, geometry.size.height)
						let symbolSide = side * 0.45

						ZStack {
							RoundedRectangle(
								cornerRadius: side * 0.2,
								style: .continuous
							)
							.fill (Color.secondary.opacity(0.1))

							Image(systemName: feature.icon)
								.symbolRenderingMode(.monochrome)
								.font(.system(size: symbolSide))
								.foregroundStyle(feature.iconColor?.color ?? .primary)
								.frame(width: symbolSide, height: symbolSide)
						}
					}
					.aspectRatio(1.0, contentMode: .fit)
					.frame(width: 52, height: 52)
					VStack(alignment: .leading, spacing: 4) {
						Text(feature.title)
							.font(.headline)
							.fontWeight(.semibold)
						Text(feature.description)
							.font(.callout)
							.foregroundColor(.secondary)
							.lineLimit(3)
					}
				}
			}
		}
	}
}

#Preview {
	OnboardingBody(
		features: Page.newFormat.features
	)
}
