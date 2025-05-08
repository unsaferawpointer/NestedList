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
		VStack(alignment: .leading, spacing: 14) {
			ForEach(features) { feature in
				HStack(alignment: .firstTextBaseline, spacing: 12) {
					Image(systemName: feature.icon)
						.font(.title3)
						.symbolRenderingMode(.monochrome)
						.foregroundColor(feature.iconColor?.value ?? .accentColor)

					VStack(alignment: .leading, spacing: 0) {
						Text(feature.title)
							.font(.title3)
							.fontWeight(.medium)
						Text(feature.description)
							.font(.body)
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
