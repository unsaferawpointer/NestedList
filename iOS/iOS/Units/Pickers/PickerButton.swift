//
//  PickerButton.swift
//  iOS
//
//  Created by Anton Cherkasov on 29.03.2026.
//

import SwiftUI
import DesignSystem

struct PickerButton: View {

	let icon: SemanticImage

	let foregroundColor: Color

	let action: () -> Void

	var body: some View {
		Button(action: action) {
			GeometryReader { geometry in
				let side = min(geometry.size.width, geometry.size.height)
				ZStack {
					RoundedRectangle(
						cornerRadius: side * 0.2,
						style: .continuous
					)
						.fill(Color.gray.opacity(0.1))
						icon.image?
							.symbolRenderingMode(.monochrome)
							.font(.system(size: side * 0.4))
							.foregroundStyle(foregroundColor)
							.frame(width: side * 0.4, height: side * 0.4)
				}
			}
			.aspectRatio(1.0, contentMode: .fit)
		}
		.buttonStyle(.plain)
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	VStack {
		PickerButton(icon: .calendar, foregroundColor: .primary) { }
	}
	.frame(width: 256, height: 256)
	.padding(24)
}
