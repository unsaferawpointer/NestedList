//
//  PickerButton.swift
//  iOS
//
//  Created by Anton Cherkasov on 29.03.2026.
//

import SwiftUI

public struct PickerButton: View {

	let icon: SemanticImage

	let foregroundColor: Color

	let backgroundColor: Color

	let action: () -> Void

	// MARK: - Initialization

	public init(
		icon: SemanticImage,
		foregroundColor: Color,
		backgroundColor: Color,
		action: @escaping () -> Void
	) {
		self.icon = icon
		self.foregroundColor = foregroundColor
		self.backgroundColor = backgroundColor
		self.action = action
	}

	public var body: some View {
		Button(action: action) {
			GeometryReader { geometry in
				let side = min(geometry.size.width, geometry.size.height)
				ZStack {
					RoundedRectangle(
						cornerRadius: side * 0.2,
						style: .continuous
					)
						.fill(backgroundColor)
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

#Preview {
	VStack {
		PickerButton(
			icon: .calendar,
			foregroundColor: .primary,
			backgroundColor: .gray.opacity(0.1)
		) {

		}
	}
	.frame(width: 256, height: 256)
	.padding(24)
}
