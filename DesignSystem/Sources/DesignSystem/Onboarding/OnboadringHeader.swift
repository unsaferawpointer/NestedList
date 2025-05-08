//
//  OnboadringHeader.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import SwiftUI

struct OnboadringHeader: View {

	var page: Page = .newFormat

	var body: some View {
		VStack(spacing: 4) {
			Image(systemName: page.image)
				.font(.system(size: 120))
				.symbolRenderingMode(.hierarchical)
				.foregroundColor(page.iconColor?.color ?? .accentColor)
				.padding(8)

			Text(page.title)
				.font(.title)
				.fontWeight(.bold)
				.lineLimit(3)

			Text(page.description)
				.font(.title2)
				.foregroundColor(.secondary)
				.lineLimit(3)
		}
	}
}

#Preview {
	OnboadringHeader()
}
